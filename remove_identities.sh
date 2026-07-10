#!/bin/bash

# parse security output
# remove either second and all older identities, or
# remove ALL 

# example output:
# # security find-identity -v
#   1) D51CFC1F8A6881B9EA3091A02CBC0807E21A644E "EAE773AF-F6C6-4667-93A9-B4D0D26A8D2A"
#   2) 7789D768D5BD10C8A4A420BB903E110720F06B01 "U446852"
#   3) 94178EFA5C5DF8BDBB9CACBA0EE6264D0118BCE1 "U446852"
#      3 valid identities found
