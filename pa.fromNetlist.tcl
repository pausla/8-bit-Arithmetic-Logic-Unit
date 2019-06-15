
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name ALU -dir "C:/Users/Student/Desktop/238992 update/ALU/planAhead_run_4" -part xc3s500efg320-4
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/Users/Student/Desktop/238992 update/ALU/ALU.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Users/Student/Desktop/238992 update/ALU} }
set_param project.pinAheadLayout  yes
set_property target_constrs_file "ALU.ucf" [current_fileset -constrset]
add_files [list {ALU.ucf}] -fileset [get_property constrset [current_run]]
link_design
