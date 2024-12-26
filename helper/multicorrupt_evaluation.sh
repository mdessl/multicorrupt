#!/bin/bash

# List of corruptions and severity levels
corruptions=("fog")
severity_levels=("1")

# Directory paths
multicorrupt_root="/MultiCorrupt/multicorrupt/"
nuscenes_data_dir="/mmdet3d/data/nuscenes"
logfile="/workspace/evaluation_log.txt"

# Model evaluation command (replace with your actual command)

# Loop over corruptions and severity levels
for corruption in "${corruptions[@]}"; do
  for severity in "${severity_levels[@]}"; do
    # Log the current configuration in the terminal
    echo "Current Configuration: Corruption=$corruption, Severity=$severity"

    # Create soft link in /workspace/data/nuscenes
    ln -s "$multicorrupt_root/$corruption/$severity" "$nuscenes_data_dir"

    # Perform model evaluation
    output=$(bash /mmdet3d/tools/dist_test.sh /mmdet3d/projects/BEVFusion/configs/sbnet_256_ordered.py /mmdet3d/bevfusion_lidar-cam_voxel0075_second_secfpn_8xb4-cyclic-20e_nus-3d-5239b1af.pth 1)

   # Save the entire output to a separate text file
    echo "$output" > "/workspace/${corruption}_${severity}_output.txt"

    # Extract NDS and mAP scores from the output
    nds=$(echo "$output" | grep "NDS:" | awk '{print $2}')
    map=$(echo "$output" | grep "mAP:" | awk '{print $2}')

    # Save results to the logfile
    echo "Corruption: $corruption, Severity: $severity, NDS: $nds, mAP: $map" >> "$logfile"

    # Remove soft link
    rm "$nuscenes_data_dir"
  done
done
