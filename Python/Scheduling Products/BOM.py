import pandas as pd
from datetime import timedelta, datetime
import sys
import time as tm
import math


def write_excel(df, file_path, sheet_name):
    with pd.ExcelWriter(file_path, mode='a', engine='openpyxl', if_sheet_exists='replace') as writer:
        df.to_excel(writer, sheet_name=sheet_name, index=False)

# Function to process orders and calculate start/end times
def process_orders(data, ls_machines_df, p_machines_df, p_operators_df, current_time=None):
    # Sort the orders by received date and due date
    data = data.sort_values(by=['DueDate', 'DueTime'])

    # Explicitly cast the 'Status' column to string to avoid FutureWarning
    data['Status'] = data['Status'].astype(str)

    # Set working hours and weekday limits
    work_start_time = timedelta(hours=8)  # 08:00 AM
    work_end_time = timedelta(hours=17)  # 17:00 PM

    if current_time is None:
        current_time = pd.to_datetime(data['ReceivedDateTime'].min())
    
    original_ls_machines = len(ls_machines_df)  # Original count of LS machines
    original_p_machines = len(p_machines_df)  # Original count of P machines
    original_p_normal_operators = len(p_machines_df[p_machines_df['Skill Type'] == 'N'])  # Normal skilled
    original_p_high_operators = len(p_machines_df[p_machines_df['Skill Type'] == 'H'])  # High skilled
    print(current_time)
    for i, row in data.iterrows():
        quantity = row['Quantity (No of Items)']
        process_type = row['MarkingProcess']
        process_time = row['Process Time Per Item']

        if math.isnan(process_time):
            process_time_per_item = row['Initial Process Time Per Item']
        else:
            process_time_per_item = process_time

        status = row['Status']

        if status != "Completed" and status != "Late":
            data.at[i, 'Status'] = 'InProgress'  # Update the status
            
            write_excel(data, file_path, 'Output')  # Write progress
            
            # Ensure the current time respects the working hours
            current_time = adjust_to_working_hours(current_time, work_start_time, work_end_time)
            print(current_time)
            # Use the baggage/unbaggage times from the dataset and handle NaN values
            baggage_start_time = row['Baggage/ Unbaggage BeginTime']
            baggage_end_time = row['Baggage/ Unbaggage End Time']
            if pd.isna(baggage_start_time):
                baggage_start_time = 0
            if pd.isna(baggage_end_time):
                baggage_end_time = 0

            if process_type == 'LS':
                machines_used, operators_used, process_time, end_time = calculate_ls_process(
                    quantity, process_time_per_item, current_time, ls_machines_df, original_ls_machines,
                    baggage_start_time, baggage_end_time, work_start_time, work_end_time)
                data.at[i, 'Used_Machines'] = ','.join(machines_used)
                data.at[i, 'Used_Operators'] = ','.join(operators_used)

            elif process_type == 'P':
                machines_used, operators_used, normal_operators_used, high_operators_used, process_time, end_time = calculate_p_process(
                    quantity, process_time_per_item, current_time, p_machines_df, p_operators_df, original_p_machines,
                    original_p_normal_operators, original_p_high_operators, baggage_start_time, baggage_end_time, work_start_time, work_end_time)
                data.at[i, 'Used_Machines'] = ','.join(machines_used)
                data.at[i, 'Used_Operators'] = ','.join(operators_used)
                data.at[i, 'Normal_Operators_Used'] = normal_operators_used
                data.at[i, 'High_Operators_Used'] = high_operators_used

            # Update the start and end times
            data.at[i, 'StartTime'] = current_time
            data.at[i, 'EndTime'] = end_time

            # Check if the order is late
            due_date = pd.to_datetime(f"{row['DueDate']} {row['DueTime']}")
            if end_time > due_date:
                data.at[i, 'Status'] = 'Late'
            else:
                data.at[i, 'Status'] = 'Completed'

            tm.sleep(2)  # Simulate delay
            print(data)

            # Update current time for the next order
            current_time = end_time
            write_excel(data, file_path, 'Output')

    return data

# Global variable to track the last allocated LS machine/operator
ls_allocation_index = 0

# Function to calculate processing for LS type with sequential allocation
def calculate_ls_process(quantity, process_time_per_item, current_time, ls_machines_df, original_ls_machines, baggage_start_time, baggage_end_time, work_start_time, work_end_time):
    global ls_allocation_index  # Access the global allocation index
    
    machines_used = []
    operators_used = []

    # Use the current allocation index to assign machine/operator
    machine = ls_machines_df['Machine'][ls_allocation_index]
    operator = ls_machines_df['Operators'][ls_allocation_index]

    # Allocate the machine and operator
    machines_used = [machine]
    operators_used = [operator]

    # Update the index for the next allocation
    ls_allocation_index = (ls_allocation_index + 1) % original_ls_machines  # Cycle through the list

    # Calculate process time and adjust for baggage handling
    process_time = process_time_per_item + baggage_start_time + baggage_end_time
    remaining_time_in_day = (work_end_time - (current_time - current_time.replace(hour=8, minute=0, second=0)))

    # If process exceeds the remaining time in the workday, move to the next working day
    while process_time > remaining_time_in_day.total_seconds() / 60:
        process_time -= remaining_time_in_day.total_seconds() / 60
        current_time = adjust_to_working_hours(current_time + timedelta(days=1), work_start_time, work_end_time)
        remaining_time_in_day = work_end_time - work_start_time  # Reset remaining time to full working day

    end_time = current_time + timedelta(minutes=int(process_time))
    return machines_used, operators_used, process_time, end_time

# Global variables to track the last allocated P machine/operator
p_allocation_index = 0

# Function to calculate processing for P type with sequential allocation
def calculate_p_process(quantity, process_time_per_item, current_time, p_machines_df, p_operators_df, original_p_machines, original_p_normal_operators, original_p_high_operators, baggage_start_time, baggage_end_time, work_start_time, work_end_time):
    global p_allocation_index  # Access the global allocation index for P machines

    machines_used = []
    operators_used = []
    normal_operators_used = 0
    high_operators_used = 0

    # Get the next machine in sequence
    machine = p_machines_df['Machine'][p_allocation_index]
    skill_type = p_machines_df['Skill Type'][p_allocation_index]  # Get the skill type for the machine (N or H)

    # Allocate the machine
    machines_used = [machine]

    # Check the skill type (Normal or High Skilled)
    if skill_type == 'H' and original_p_high_operators > 0:
        # Allocate high-skilled operator
        operator = p_machines_df['Operators'][p_allocation_index]
        high_operators_used = 1
        process_time = p_operators_df.loc[p_operators_df['Order Type'] == p_operators_df['Order Type'][p_allocation_index], 'H'].values[0]
    else:
        # Allocate normal-skilled operator
        operator = p_machines_df['Operators'][p_allocation_index]
        normal_operators_used = 1
        process_time = p_operators_df.loc[p_operators_df['Order Type'] == p_operators_df['Order Type'][p_allocation_index], 'N'].values[0]

    # Allocate the operator
    operators_used = [operator]

    # Update the index for the next allocation
    p_allocation_index = (p_allocation_index + 1) % original_p_machines  # Cycle through the list

    # Add baggage handling time to process time
    process_time += baggage_start_time + baggage_end_time
    remaining_time_in_day = (work_end_time - (current_time - current_time.replace(hour=8, minute=0, second=0)))

    # If process exceeds the remaining time in the workday, move to the next working day
    while process_time > remaining_time_in_day.total_seconds() / 60:
        process_time -= remaining_time_in_day.total_seconds() / 60
        current_time = adjust_to_working_hours(current_time + timedelta(days=1), work_start_time, work_end_time)
        remaining_time_in_day = work_end_time - work_start_time  # Reset remaining time to full working day

    end_time = current_time + timedelta(minutes=int(process_time))
    return machines_used, operators_used, normal_operators_used, high_operators_used, process_time, end_time


# Function to find the last end time for orders in progress
def get_last_end_time(data):
    # Filter to only include 'InProgress' or empty status rows
    in_progress_data = data[data['Status'].isin(['InProgress', None, ''])]
    if not in_progress_data.empty:
        last_end_time = pd.to_datetime(in_progress_data['EndTime'].max())
        if pd.notnull(last_end_time):
            return last_end_time
    return None

# Adjust working hours and skip weekends if necessary
def adjust_to_working_hours(current_time, work_start_time, work_end_time):
    work_start_time_dt = (datetime.min + work_start_time).time()  # Convert timedelta to time
    work_end_time_dt = (datetime.min + work_end_time).time()  # Convert timedelta to time

    # Check if current time is outside working hours or on a weekend
    if current_time.weekday() >= 5:  # Saturday or Sunday
        current_time += timedelta(days=(7 - current_time.weekday()))  # Move to Monday
        current_time = datetime.combine(current_time.date(), work_start_time_dt)
    elif current_time.time() < work_start_time_dt or current_time.time() >= work_end_time_dt:
        current_time = datetime.combine(current_time.date() + timedelta(days=1), work_start_time_dt)

    return current_time

# Load the Excel file and prepare data

def main():
    # Use readline to ensure we're reading one line
    input_data = sys.stdin.readline().strip()
    #input_data="Initial"
    # Debug print to check if we're receiving the input correctly
    print(f"Received input: {input_data}")
    file_path = 'Data Sample.xlsx'
    if input_data == "Initial":
        print("Processing initial data")
        data_df = pd.read_excel(file_path, sheet_name='Data')
        # Initialize columns for status
        data_df['StartTime'] = None
        data_df['EndTime'] = None
        #data_df['Status'] = 'Pending'
        data_df['Used_Machines'] = None
        data_df['Used_Operators'] = None
        data_df['Normal_Operators_Used'] = 0
        data_df['High_Operators_Used'] = 0
        
        # Convert ReceivedTime to string for concatenation
        data_df['ReceivedTime'] = data_df['ReceivedTime'].astype(str)
        data_df['ReceivedDateTime'] = pd.to_datetime(data_df['ReceivedDate'].astype(str) + ' ' + data_df['ReceivedTime'])
        # Set last_end_time to None for initial processing
        last_end_time = None
    elif input_data=="Start":
        print("Processing Previous data")
        data_df= pd.read_excel(file_path, sheet_name='Output')
        # Find the last EndTime for orders in progress or unprocessed
        last_end_time = get_last_end_time(data_df)
        if last_end_time:
            print(f"Starting from last end time: {last_end_time}")
        else:
            print("No in-progress or pending orders found, starting from the earliest received order")
            last_end_time = pd.to_datetime(data_df['EndTime'].max())

    # Load the machine and operator information from the LS and P sheets
    ls_machines_df = pd.read_excel(file_path, sheet_name='Laser')  # Contains LS machines and operators
    p_machines_df = pd.read_excel(file_path, sheet_name='P')  # Contains P machines and operator types
    p_operators_df = pd.read_excel(file_path, sheet_name='P_PTime')  # Contains operator skill types and processing times

    # Print columns to identify the correct operator column
    print("Columns in p_operators_df:", p_operators_df.columns)

    
    
    print(data_df.head())
    #write_excel(data_df, file_path, 'Output1')
    # Process the orders and calculate times using the loaded machines and operators
    processed_data = process_orders(data_df, ls_machines_df, p_machines_df, p_operators_df, last_end_time)
    # Ensure ReceivedTime, DueTime, StartTime, and EndTime are in datetime format before formatting

    # Ensure ReceivedTime, DueTime, StartTime, and EndTime are in datetime format before formatting
    processed_data['ReceivedTime'] = pd.to_datetime(processed_data['ReceivedTime'], format='%H:%M:%S', errors='coerce').dt.strftime('%H:%M')
    processed_data['DueTime'] = pd.to_datetime(processed_data['DueTime'], format='%H:%M:%S', errors='coerce').dt.strftime('%H:%M')
    
    # Format StartTime and EndTime to 'YYYY-MM-DD'
    processed_data['ReceivedDate'] = pd.to_datetime(processed_data['ReceivedDate'], errors='coerce').dt.strftime('%Y-%m-%d')
    processed_data['DueDate'] = pd.to_datetime(processed_data['DueDate'], errors='coerce').dt.strftime('%Y-%m-%d')
    processed_data['ReceivedDateTime'] = pd.to_datetime(processed_data['ReceivedDateTime'], errors='coerce').dt.strftime('%Y-%m-%d %H:%M')
    processed_data['StartTime'] = pd.to_datetime(processed_data['StartTime'], errors='coerce').dt.strftime('%Y-%m-%d %H:%M')
    processed_data['EndTime'] = pd.to_datetime(processed_data['EndTime'], errors='coerce').dt.strftime('%Y-%m-%d %H:%M')
    write_excel(processed_data, file_path, 'Output')
file_path = 'Data Sample.xlsx'

if __name__ == "__main__":
    main()