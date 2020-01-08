# Script for file conversions among ParFlow formats - ONE FILE
lappend   auto_path $env(PARFLOW_DIR)/bin
package   require parflow
namespace import Parflow::*
##### USER INPUTS ###################################################
# File Input filename.ext (ext = pfb, silo, sa)

# for {set i 1} {$i <= 365} {incr i } {
# set j [format "%05d" $i]
set filename1 "../EcoSLIM/gr_sp7.out.evaptrans.00001"
set ext1 "sa"
# if ext1 is "sa", set grid information below, in line 28

# Save Option
#set pfb "true"
set pfb "true"
set silo "false"
#set silo "false"
#set sa "true"
set sa "false"

# Output Filename
set outfile1 $filename1

# Load file (leave alone)
set file1 [pfload $filename1.$ext1]

if {$ext1 == "sa"} then {
# Simple ascii set grid info (if needed to save from SA)
# Set grid info -- pfsetgrid {nx ny nz} {x0 y0 z0} {dx dy dz} $file
pfsetgrid {91.0 70.0 20.0} {0.0 0.0 0.0} {90.0 90.0 0.1} $file1}
#####################################################################


# Save as .pfb
if {$pfb == true} then {
pfsave $file1 -pfb $outfile1.pfb
}

# Save as .silo
if {$silo == true} then {
pfsave $file1 -silo $filename1.silo
}

# Save as .sa (Simple ASCII txt file)
if {$sa == true} then {

pfsave $file1 -sa $outfile1.txt
}
