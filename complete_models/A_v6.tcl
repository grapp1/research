# 20190927 - A_v5.tcl re-spinning up scenario A with solid file mask and CLM
# overland flow on
# modified from A_v4.tcl
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
cd "./A_v6_outputs"

# ParFlow Inputs
# file copy -force "../../parflow_input/slopes.nc" .
# file copy -force "../../parflow_input/IndicatorFile_Gleeson.50z.pfb"   .
# file copy -force "../../parflow_input/press.init.nc"  .
#
# CLM Inputs
# file copy -force "../../clm_input/drv_clmin.dat" .
file copy -force "../CLM/drv_vegp.dat"  .
file copy -force "../CLM/drv_vegm.dat"  .

file copy -force "../garrett_domain.pfsol" .
# file copy -force "../../clm_input/metForcing.nc"  .

puts "Files Copied"

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
pfset ComputationalGrid.NZ                20
# 20 vertical layers


#-----------------------------------------------------------------------------
# Names of the GeomInputs
#-----------------------------------------------------------------------------
# pfset GeomInput.Names                     "box_input indi_input"
# pfset GeomInput.Names                     "box_input"

pfset GeomInput.Names                 "domaininput"

pfset GeomInput.domaininput.GeomName  domain

pfset GeomInput.domaininput.InputType  SolidFile
pfset GeomInput.domaininput.GeomNames  domain
pfset GeomInput.domaininput.FileName   "garrett_domain.pfsol"

pfset Geom.domain.Patches             "edge top bottom"

#-----------------------------------------------------------------------------
# Domain Geometry
#-----------------------------------------------------------------------------
pfset Geom.domain.Lower.X                        0.0
pfset Geom.domain.Lower.Y                        0.0
pfset Geom.domain.Lower.Z                        0.0

pfset Geom.domain.Upper.X                         8190.0
pfset Geom.domain.Upper.Y                         6300.0
pfset Geom.domain.Upper.Z                         2000.0
##pfset Geom.domain.Patches             "x-lower x-upper y-lower y-upper z-lower z-upper"

#-----------------------------------------------------------------------------
# Indicator Geometry Input
#-----------------------------------------------------------------------------
# pfset GeomInput.indi_input.InputType      IndicatorField
# pfset GeomInput.indi_input.GeomNames      "s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13 g1 g2 g3 g4 g5 g6 g7 g8"
# pfset Geom.indi_input.FileName            "IndicatorFile_Gleeson.50z.pfb"

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
pfset TimingInfo.BaseUnit                 1.0
pfset TimingInfo.StartCount               0.0
pfset TimingInfo.StartTime                0.0
pfset TimingInfo.StopTime                 8760.0
pfset TimingInfo.DumpInterval             1.0
pfset TimeStep.Type                       Constant
pfset TimeStep.Value                      1.0

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

#-----------------------------------------------------------------------------
# Boundary Conditions
#-----------------------------------------------------------------------------
pfset BCPressure.PatchNames                   "edge top bottom"

#no flow boundaries for the land borders and the bottom
pfset Patch.edge.BCPressure.Type		      FluxConst
pfset Patch.edge.BCPressure.Cycle		      "constant"
pfset Patch.edge.BCPressure.alltime.Value	      0.0

pfset Patch.bottom.BCPressure.Type		      FluxConst
pfset Patch.bottom.BCPressure.Cycle		      "constant"
pfset Patch.bottom.BCPressure.alltime.Value	      0.0

## overland flow boundary condition with long-term average recharge over study area
## 20190919 reduced recharge to the net P-ET from CLM runs
pfset Patch.top.BCPressure.alltime.Value	      0.0
pfset Patch.top.BCPressure.Type		      OverlandFlow
pfset Patch.top.BCPressure.Cycle		      "constant"
#pfset Patch.top.BCPressure.alltime.Value	      0.0


#-----------------------------------------------------------------------------
# Topo slopes in x-direction
#-----------------------------------------------------------------------------
pfset TopoSlopesX.Type                                "PFBFile"
pfset TopoSlopesX.GeomNames                           "domain"
pfset TopoSlopesX.FileName                            "../garrett.slopex.pfb"

#-----------------------------------------------------------------------------
# Topo slopes in y-direction
#-----------------------------------------------------------------------------
pfset TopoSlopesY.Type                                "PFBFile"
pfset TopoSlopesY.GeomNames                           "domain"
pfset TopoSlopesY.FileName                            "../garrett.slopey.pfb"

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
pfset Geom.domain.Saturation.SRes         0.1
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
pfset Solver.LSM                                      CLM
pfset Solver.CLM.CLMFileDir                           "./"
pfset Solver.PrintCLM                                 True
pfset Solver.CLM.Print1dOut                           False
pfset Solver.BinaryOutDir                             False
pfset Solver.CLM.DailyRST                      		  True
pfset Solver.CLM.SingleFile                       	  True
pfset Solver.CLM.CLMDumpInterval                      168
pfset Solver.CLM.WriteLogs                            False
pfset Solver.CLM.WriteLastRST                         True

pfset Solver.CLM.MetForcing                           1D
pfset Solver.CLM.MetFileName                          "Forcing1D_gr.txt"
pfset Solver.CLM.MetFilePath                          "../CLM/"
#pfset Solver.CLM.MetFileNT                            24
pfset Solver.CLM.IstepStart                           1.0

pfset Solver.CLM.EvapBeta                             Linear
pfset Solver.CLM.VegWaterStress                       Saturation
pfset Solver.CLM.ResSat                               0.1
pfset Solver.CLM.WiltingPoint                         0.12
pfset Solver.CLM.FieldCapacity                        0.98
pfset Solver.CLM.IrrigationType                       none

#---------------------------------------------------------
# Initial conditions: water pressure
#---------------------------------------------------------
# pfset ICPressure.Type                                 NCFile
# pfset ICPressure.GeomNames                            domain
# pfset Geom.domain.ICPressure.RefPatch                   z-upper
# pfset Geom.domain.ICPressure.FileName                   press.init.nc

pfset ICPressure.Type								PFBFile
pfset ICPressure.GeomNames							domain
pfset Geom.domain.ICPressure.RefPatch               top
pfset Geom.domain.ICPressure.FileName				A_v5.out.press.01042.pfb

#pfset ICPressure.Type								Constant
#pfset ICPressure.GeomNames							domain
#pfset Geom.domain.ICPressure.RefPatch               z-upper
#pfset Geom.domain.ICPressure.Value				     -1

#----------------------------------------------------------------
# Outputs
# ------------------------------------------------------------
#Writing output (all pfb):
pfset Solver.PrintSubsurf                             True
pfset Solver.PrintPressure                            True
pfset Solver.PrintSaturation                          True
pfset Solver.PrintMask                                False
pfset Solver.PrintVelocities   			              True

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

pfset Solver.PrintEvapTrans                           True


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
### In this run nz = 20; dz = 100; total depth 1000;
### Layers Thickness [m]
### Bottom layer - 1st row
### Top layer - last row
pfset dzScale.GeomNames domain
pfset dzScale.Type nzList
pfset dzScale.nzListNumber 20
pfset Cell.0.dzScale.Value 2.0
pfset Cell.1.dzScale.Value 2.0
pfset Cell.2.dzScale.Value 2.0
pfset Cell.3.dzScale.Value 1.0
pfset Cell.4.dzScale.Value 1.0
pfset Cell.5.dzScale.Value .50
pfset Cell.6.dzScale.Value .50
pfset Cell.7.dzScale.Value .20
pfset Cell.8.dzScale.Value .20
pfset Cell.9.dzScale.Value .20
pfset Cell.10.dzScale.Value .20
pfset Cell.11.dzScale.Value .10
pfset Cell.12.dzScale.Value 0.02
pfset Cell.13.dzScale.Value 0.02
pfset Cell.14.dzScale.Value 0.02
pfset Cell.15.dzScale.Value 0.02
pfset Cell.16.dzScale.Value 0.01
pfset Cell.17.dzScale.Value 0.006
pfset Cell.18.dzScale.Value 0.003
pfset Cell.19.dzScale.Value 0.001

pfset Solver.MaxIter                                  25000000
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

# pfset NetCDF.NumStepsPerFile			5
# pfset NetCDF.CLMNumStepsPerFile                 24
# pfset NetCDF.WritePressure				True
# pfset NetCDF.WriteSaturation			True
# pfset NetCDF.WriteMannings				True
# pfset NetCDF.WriteSubsurface			True
# pfset NetCDF.WriteSlopes				True
# pfset NetCDF.WriteMask					True
# pfset NetCDF.WriteDZMultiplier			True
# pfset NetCDF.WriteEvapTrans				True
# pfset NetCDF.WriteEvapTransSum			True
# pfset NetCDF.WriteOverlandSum			True
# pfset NetCDF.WriteOverlandBCFlux		True
# pfset NetCDF.WriteCLM					True

pfset OverlandFlowSpinUp  	0
# 0 = overland flow on, 1 = overland flow off

#-----------------------------------------------------------------------------
# Distribute inputs
#-----------------------------------------------------------------------------
pfset ComputationalGrid.NX                91
pfset ComputationalGrid.NY                70
pfset ComputationalGrid.NZ                1
pfdist "../garrett.slopex.pfb"
pfdist "../garrett.slopey.pfb"
pfset ComputationalGrid.NZ                20
pfdist A_v5.out.press.01042.pfb

# pfset ComputationalGrid.NX                91
# pfset ComputationalGrid.NY                70
# pfset ComputationalGrid.NZ                20
# pfdist IndicatorFile_Gleeson.50z.pfb
#pfdist press.init.pfb

#-----------------------------------------------------------------------------
# Run Simulation
#-----------------------------------------------------------------------------
set runname "A_v6"
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
pfundist "../garrett.slopex.pfb"
pfundist "../garrett.slopey.pfb"
#pfundist ComputationalGrid.NZ                20
# pfundist garrett.out.press.00012.pfb
#
puts "ParFlow run Complete"
#
#
