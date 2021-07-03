##########################################
### How to properly produce SimPoints ####
##########################################
############################
### Georgios Vavouliotis ###
############################

0. Download pin 3.11 (pin-3.11-97998-g7ecce2dac-gcc-linux) and place it inside ChampSim-Tracing directory

1. cd tracer

2. fix paths in clean_tracer.sh and make_tracer.sh 

3. bash clean_tracer.sh

4. uncomment line 6 in make_tracer.sh # builds BBV vectors

5. bash make_tracer

6. comment line 6 in make_tracer.sh and uncomment line 5 # the actual tracer

7. bash make_tracer

8. cd ../out_tracer

9. fix paths in tracer.sh

10. mkdir bbv

11. check the example and the arguments in tracer.sh

12. bash tracer.sh

13. navigate to ./bbv -- you should see a file named myfirstsimpoint.bb -- check if it looks like the example.bb that you can find in the directory

14. open Makefile

15. The last number in line 2 corresponds to the maximum number of the provided simpoints

16. make 

17. you should find in ./output two files per .bb file (.simpoint, .weight)

18. .weights files contain tuples of (weight, simpoint_id)

	.simpoints files contain tuples of (start, simpoint_id)

19. you decide which simpoints you want to trace based on step 18

20. final step, open ../simpoint_tracer.sh, change the paths, set the TRACING_POINT based on step 19

21. bash simpoint_tracer

