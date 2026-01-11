#!/bin/bash
#SBATCH --job-name hemelb-build
#SBATCH -o log/%x.%j.out
#SBATCH -e log/%x.%j.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=56
#SBATCH -t 00:10:00

set -e

EXEC_PATH="FullBuild.sh"
ENV="$(pwd)/env.sh"

. "${ENV}"

for var in "PP" "VP"
do
	sh "${EXEC_PATH}" "$var"
done
