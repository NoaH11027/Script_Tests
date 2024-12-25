#!/bin/bash
#
############################################################################################################
#
# SSD Performance Measurement
# 
# Variante
#
# 2024-12-25
#
# Mark Lüthke
#
############################################################################################################

dd if=/dev/sda | pv -br | dd of=/dev/null

#
# execute with timeout commando run for a certain time period
# timeout 10s dd if=/dev/sda | pv -br | dd of=/dev/null
#