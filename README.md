# FileIntegrity
This is a program to test for file integrity using powershell

User has two options.
Option A) Will the the following: Collect New Baseline
     1)Calculate the hash value from a given target file
     2)Store the file hash in Baseline.txt
Option B) Will do the following: Monitor Files with saved Baseline.txt
     1) Load the file hash from the baseline.txt
     2) Loop through each file target then calculate the hash and compare the file hash to baseline.txt
