# Author: Yuewen FANG
# Date: 2020 July 2nd
# This Julia script is used for correcting the weight of q point.
# The input file is the crystal cooridnates of k-point in a scf calculations generated by pw.x using a uniform grid
# Since the weight is 2. But q is spinless, its total weight is 1. So the weight of each q should be multipy 0.5.

using CSV
using DataFrames
## Note that Q.txt is taken from the output of scf.out with kgrid of 40*40*40, you must use the crystal coordinates that
##is required by the EPW code: see loadqmesh.f90 in its source code
df = CSV.File("./Q.txt", header=false, delim=" ", ignorerepeated=true)  |> DataFrame!
fout = open("Q-weight1.txt", "w")
df[!,10] = df[!,10]/2
# round_ratio = round(ratio, digits=2)
total_weight = sum(df[!,10])

function check_version(answer)
    if answer=="Yes"
        return(true)
    else
        return(false)
    end
end

println("Do you use EPW v4.3? Choose Yes or No")
answer = readline()
if check_version(answer) 
    CSV.write(fout, df, delim=' ',writeheader=false)
    println("Note that this generated Q-weight1.txt only supports lower EPW versions, v4.3")
else
    df1 = DataFrames.select(df,:5,:6,:7,:10)
    total_rows = nrow(df1)
    write(fout, "  $total_rows")
    write(fout, "\n")
    line = 0
    for i in eachrow(df1)
        global line
        line = line + 1
#       print(i[3])
        j = i[3]
        k = chop(j,tail=2) # here it is SubString{String}       
        df1[!,3][line] = k 
    end
    CSV.write(fout, df1, delim=' ',writeheader=false, append=true)
    println("Note that this generated Q-weight1.txt only supports high EPW versions, v5.2")
            
end
close(fout)
