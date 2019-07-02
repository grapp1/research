# 20190627 - pressure_test.tcl - testing hydrostatic conditions
# checking pressure outputs to see whether they make sense
# overland flow on
# modified from o_spinup7_v3.tcl
# DETAILS:
# Arugments are 1) runname 2) year

# Import the ParFlow TCL package
lappend   auto_path $env(PARFLOW_DIR)/bin
package   require parflow
namespace import Parflow::*

pfset     FileVersion    4

#-----------------------------------------------------------------------------
# Set Processor topology
#-----------------------------------------------------------------------------
pfset Process.Topology.P 7
pfset Process.Topology.Q 4
pfset Process.Topology.R 1

#-----------------------------------------------------------------------------
# Make a directory for the simulation and copy inputs into it
#-----------------------------------------------------------------------------
# exec mkdir "Outputs"
cd "./press_test"

#-----------------------------------------------------------------------------
# Computational Grid
#-----------------------------------------------------------------------------
pfset ComputationalGrid.Lower.X           0.0
pfset ComputationalGrid.Lower.Y           0.0
pfset ComputationalGrid.Lower.Z           0.0

pfset ComputationalGrid.DX                90.0
pfset ComputationalGrid.DY                90.0
pfset ComputationalGrid.DZ                100.0

pfset ComputationalGrid.NX                91
pfset ComputationalGrid.NY                70
pfset ComputationalGrid.NZ                10
# 20 vertical layers


#-----------------------------------------------------------------------------
# Names of the GeomInputs
#-----------------------------------------------------------------------------
# pfset GeomInput.Names                     "box_input indi_input"
 pfset GeomInput.Names                     "box_input"

#-----------------------------------------------------------------------------
# Domain Geometry Input
#-----------------------------------------------------------------------------
pfset GeomInput.box_input.InputType      Box
pfset GeomInput.box_input.GeomName      domain

#-----------------------------------------------------------------------------
# Domain Geometry
#-----------------------------------------------------------------------------
pfset Geom.domain.Lower.X                        0.0
pfset Geom.domain.Lower.Y                        0.0
pfset Geom.domain.Lower.Z                        0.0

pfset Geom.domain.Upper.X                         8190.0
pfset Geom.domain.Upper.Y                         6300.0
pfset Geom.domain.Upper.Z                         1000.0
pfset Geom.domain.Patches             "x-lower x-upper y-lower y-upper z-lower z-upper"

#-----------------------------------------------------------------------------
# Permeability (values in m/hr)
#-----------------------------------------------------------------------------
# pfset Geom.Perm.Names                     "domain s1 s2 s3 s4 s5 s6 s7 s8 s9 g2 g3 g6 g8"
pfset Geom.Perm.Names                     "domain"

# 20190621 updated K to be equivalent to 5e-7 m/s
pfset Geom.domain.Perm.Type           Constant
pfset Geom.domain.Perm.Value          0.0018


pfset Perm.TensorType                     TensorByGeom
pfset Geom.Perm.TensorByGeom.Names        "domain"
pfset Geom.domain.Perm.TensorValX         1.0d0
pfset Geom.domain.Perm.TensorValY         1.0d0
pfset Geom.domain.Perm.TensorValZ         1.0d0

#-----------------------------------------------------------------------------
# Specific Storage
#-----------------------------------------------------------------------------
pfset SpecificStorage.Type                Constant
pfset SpecificStorage.GeomNames           "domain"
pfset Geom.domain.SpecificStorage.Value   1.0e-5

#-----------------------------------------------------------------------------
# Phases
#-----------------------------------------------------------------------------
pfset Phase.Names                         "water"
pfset Phase.water.Density.Type            Constant
pfset Phase.water.Density.Value           1.0
pfset Phase.water.Viscosity.Type          Constant
pfset Phase.water.Viscosity.Value         1.0

#-----------------------------------------------------------------------------
# Contaminants
#-----------------------------------------------------------------------------
pfset Contaminants.Names                  ""

#-----------------------------------------------------------------------------
# Gravity
#-----------------------------------------------------------------------------
pfset Gravity                             1.0

#-----------------------------------------------------------------------------
# Timing (time units is set by units of permeability)
#-----------------------------------------------------------------------------
pfset TimingInfo.BaseUnit        1
pfset TimingInfo.StartCount      0
pfset TimingInfo.StartTime       0.0
pfset TimingInfo.StopTime        2000000.0
pfset TimingInfo.DumpInterval    10000
pfset TimeStep.Type              Growth
pfset TimeStep.InitialStep       10
pfset TimeStep.GrowthFactor      1.1
pfset TimeStep.MaxStep           1000000
pfset TimeStep.MinStep           0.1

#-----------------------------------------------------------------------------
# Porosity
#-----------------------------------------------------------------------------
# pfset Geom.Porosity.GeomNames             "domain s1 s2 s3 s4 s5 s6 s7 s8 s9"
pfset Geom.Porosity.GeomNames             "domain"

pfset Geom.domain.Porosity.Type          Constant
pfset Geom.domain.Porosity.Value         0.1

#-----------------------------------------------------------------------------
# Domain
#-----------------------------------------------------------------------------
pfset Domain.GeomName                     "domain"

#----------------------------------------------------------------------------
# Mobility
#----------------------------------------------------------------------------
pfset Phase.water.Mobility.Type        Constant
pfset Phase.water.Mobility.Value       1.0

#-----------------------------------------------------------------------------
# Wells
#-----------------------------------------------------------------------------
pfset Wells.Names                         ""

#-----------------------------------------------------------------------------
# Time Cycles
#-----------------------------------------------------------------------------
pfset Cycle.Names "constant"
pfset Cycle.constant.Names              "alltime"
pfset Cycle.constant.alltime.Length      1
pfset Cycle.constant.Repeat             -1

# rainfall and recession time periods are defined here
# rain for 7 hours, recession for 3 hours

#pfset Cycle.rainrec.Names                 "rain rec"
#pfset Cycle.rainrec.rain.Length           10
#pfset Cycle.rainrec.rec.Length             0
#pfset Cycle.rainrec.Repeat                -1

#-----------------------------------------------------------------------------
# Boundary Conditions
#-----------------------------------------------------------------------------
pfset BCPressure.PatchNames                   [pfget Geom.domain.Patches]

pfset Patch.x-lower.BCPressure.Type		      FluxConst
pfset Patch.x-lower.BCPressure.Cycle		      "constant"
pfset Patch.x-lower.BCPressure.alltime.Value	      0.0

pfset Patch.y-lower.BCPressure.Type		      FluxConst
pfset Patch.y-lower.BCPressure.Cycle		      "constant"
pfset Patch.y-lower.BCPressure.alltime.Value	      0.0

## overland flow boundary condition with long-term average recharge over study area - added to both bottom and top
pfset Patch.z-lower.BCPressure.Type		      FluxConst
pfset Patch.z-lower.BCPressure.Cycle		      "constant"
pfset Patch.z-lower.BCPressure.alltime.Value	      0.0

pfset Patch.x-upper.BCPressure.Type		      FluxConst
pfset Patch.x-upper.BCPressure.Cycle		      "constant"
pfset Patch.x-upper.BCPressure.alltime.Value	      0.0

pfset Patch.y-upper.BCPressure.Type		      FluxConst
pfset Patch.y-upper.BCPressure.Cycle		      "constant"
pfset Patch.y-upper.BCPressure.alltime.Value	      0.0

## overland flow boundary condition with long-term average recharge over study area
pfset Patch.z-upper.BCPressure.Type		      OverlandFlow
pfset Patch.z-upper.BCPressure.Cycle		      "constant"
pfset Patch.z-upper.BCPressure.alltime.Value	  -3.5e-5

#-----------------------------------------------------------------------------
# Topo slopes in x-direction
#-----------------------------------------------------------------------------
pfset TopoSlopesX.Type                                "PFBFile"
pfset TopoSlopesX.GeomNames                           "domain"
pfset TopoSlopesX.FileName                            "../Outputs/garrett.slopex.pfb"

#-----------------------------------------------------------------------------
# Topo slopes in y-direction
#-----------------------------------------------------------------------------
pfset TopoSlopesY.Type                                "PFBFile"
pfset TopoSlopesY.GeomNames                           "domain"
pfset TopoSlopesY.FileName                            "../Outputs/garrett.slopey.pfb"

#-----------------------------------------------------------------------------
# Mannings coefficient
#-----------------------------------------------------------------------------
pfset Mannings.Type                                   "Constant"
pfset Mannings.GeomNames                              "domain"
pfset Mannings.Geom.domain.Value                      5.52e-6

#-----------------------------------------------------------------------------
# Relative Permeability
#-----------------------------------------------------------------------------
pfset Phase.RelPerm.Type                  VanGenuchten
# pfset Phase.RelPerm.GeomNames             "domain s1 s2 s3 s4 s5 s6 s7 s8 s9 "
pfset Phase.RelPerm.GeomNames             "domain"

pfset Geom.domain.RelPerm.Alpha           3.5
pfset Geom.domain.RelPerm.N               2.0

#-----------------------------------------------------------------------------
# Saturation
#-----------------------------------------------------------------------------
pfset Phase.Saturation.Type               VanGenuchten
# pfset Phase.Saturation.GeomNames          "domain s1 s2 s3 s4 s5 s6 s7 s8 s9 "
pfset Phase.Saturation.GeomNames          "domain"

pfset Geom.domain.Saturation.Alpha        3.5
pfset Geom.domain.Saturation.N            2.
pfset Geom.domain.Saturation.SRes         0.2
pfset Geom.domain.Saturation.SSat         1.0

#-----------------------------------------------------------------------------
# Phase sources:
#-----------------------------------------------------------------------------
pfset PhaseSources.water.Type                         "Constant"
pfset PhaseSources.water.GeomNames                    "domain"
pfset PhaseSources.water.Geom.domain.Value            0.0

#----------------------------------------------------------------
# CLM Settings:
# ------------------------------------------------------------
pfset Solver.LSM                                      none

#---------------------------------------------------------
# Initial conditions: water pressure
#---------------------------------------------------------
# pfset ICPressure.Type                                 NCFile
# pfset ICPressure.GeomNames                            domain
# pfset Geom.domain.ICPressure.RefPatch                   z-upper
# pfset Geom.domain.ICPressure.FileName                   press.init.nc

#pfset ICPressure.Type								PFBFile
#pfset ICPressure.GeomNames							domain
#pfset Geom.domain.ICPressure.RefPatch               z-upper
#pfset Geom.domain.ICPressure.FileName				gr_sp7_RESTART.out.press.00065.pfb

pfset ICPressure.Type								Constant
pfset ICPressure.GeomNames							domain
pfset Geom.domain.ICPressure.RefPatch               z-upper
pfset Geom.domain.ICPressure.Value				     -1

#----------------------------------------------------------------
# Outputs
# ------------------------------------------------------------
#Writing output (all pfb):
pfset Solver.PrintSubsurf                             False
pfset Solver.PrintPressure                            True
pfset Solver.PrintSaturation                          True
pfset Solver.PrintMask                                False
pfset Solver.PrintVelocities   			                  False

pfset Solver.WriteCLMBinary                           False
pfset Solver.PrintCLM                                 False
pfset Solver.WriteSiloSpecificStorage                 False
pfset Solver.WriteSiloMannings                        False
pfset Solver.WriteSiloMask                            False
pfset Solver.WriteSiloSlopes                          False
pfset Solver.WriteSiloSubsurfData                     False
pfset Solver.WriteSiloPressure                        False
pfset Solver.WriteSiloSaturation                      False
pfset Solver.WriteSiloEvapTrans                       False
pfset Solver.WriteSiloEvapTransSum                    False
pfset Solver.WriteSiloOverlandSum                     False
pfset Solver.WriteSiloCLM                             False


#-----------------------------------------------------------------------------
# Exact solution specification for error calculations
#-----------------------------------------------------------------------------
pfset KnownSolution                                   NoKnownSolution

#-----------------------------------------------------------------------------
# Set solver parameters
#-----------------------------------------------------------------------------
# ParFlow Solution
pfset Solver                                          Richards
pfset Solver.TerrainFollowingGrid                     True

#-----------------------------------------------------------------------------
# Setting up vertical layering
#-----------------------------------------------------------------------------
pfset Solver.Nonlinear.VariableDz                     True
### Set VariableDz to be true
### Indicate number of layers (nzlistnumber), which is the same as nz
### (1) There is nz*dz = total depth to allocate,
### (2) Each layers thickness is dz*dzScale, and
### (3) Assign the layer thickness from the bottom up.
### In this run nz = 10; dz = 100; total depth 1000;
### Layers Thickness [m]
### Bottom layer - 1st row
### Top layer - last row
pfset dzScale.GeomNames domain
pfset dzScale.Type nzList
pfset dzScale.nzListNumber 10
pfset Cell.0.dzScale.Value .20
pfset Cell.1.dzScale.Value .10
pfset Cell.2.dzScale.Value 0.02
pfset Cell.3.dzScale.Value 0.02
pfset Cell.4.dzScale.Value 0.02
pfset Cell.5.dzScale.Value 0.02
pfset Cell.6.dzScale.Value 0.01
pfset Cell.7.dzScale.Value 0.006
pfset Cell.8.dzScale.Value 0.003
pfset Cell.9.dzScale.Value 0.001

pfset Solver.MaxIter                                  25000
pfset Solver.Drop                                     1E-20
pfset Solver.AbsTol                                   1E-8
pfset Solver.MaxConvergenceFailures                   8
pfset Solver.Nonlinear.MaxIter                        80
pfset Solver.Nonlinear.ResidualTol                    1e-6

## new solver settings for Terrain Following Grid
pfset Solver.Nonlinear.EtaChoice                         EtaConstant
pfset Solver.Nonlinear.EtaValue                          0.001
pfset Solver.Nonlinear.UseJacobian                       True
pfset Solver.Nonlinear.DerivativeEpsilon                 1e-16
pfset Solver.Nonlinear.StepTol				 			1e-30
pfset Solver.Nonlinear.Globalization                     LineSearch
pfset Solver.Linear.KrylovDimension                      70
pfset Solver.Linear.MaxRestarts                           2

pfset Solver.Linear.Preconditioner                       PFMG
pfset Solver.Linear.Preconditioner.PCMatrixType     FullJacobian

pfset OverlandFlowSpinUp  	0
# 0 = overland flow on, 1 = overland flow off

#-----------------------------------------------------------------------------
# Distribute inputs
#-----------------------------------------------------------------------------
pfset ComputationalGrid.NX                91
pfset ComputationalGrid.NY                70
pfset ComputationalGrid.NZ                1
pfdist ../Outputs/garrett.slopex.pfb
pfdist ../Outputs/garrett.slopey.pfb
pfset ComputationalGrid.NZ                10
#pfdist gr_sp7_RESTART.out.press.00065.pfb

# pfset ComputationalGrid.NX                91
# pfset ComputationalGrid.NY                70
# pfset ComputationalGrid.NZ                20
# pfdist IndicatorFile_Gleeson.50z.pfb
#pfdist press.init.pfb

#-----------------------------------------------------------------------------
# Run Simulation
#-----------------------------------------------------------------------------
set runname "press_test"
puts $runname
#pfwritedb $runname
pfrun    $runname
#
##-----------------------------------------------------------------------------
## Undistribute outputs
##-----------------------------------------------------------------------------
pfundist $runname
#pfundist press.init.pfb
pfset ComputationalGrid.NZ                1
pfundist ../Outputs/garrett.slopex.pfb
pfundist ../Outputs/garrett.slopey.pfb
#pfundist ComputationalGrid.NZ                20
# pfundist garrett.out.press.00012.pfb
#
puts "ParFlow run Complete"
#
#
