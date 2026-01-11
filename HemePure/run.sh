#!/bin/bash
#SBATCH --job-name hemelb-test
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=112
#SBATCH --cpus-per-task=1
#SBATCH --output=log/%x.%j.out
#SBATCH --error=log/%x.%j.err
#SBATCH --time=00:15:00

set -e

# you need to move hemelab-PP optimized to hemelab-opt or whatever you want
VARIENT="opt"

# CASE_PATH="$(pwd)/cases/SixBranch_3inlet"
CASE_PATH="$(pwd)/Bifurcation-TINY"
CASE_NAME="input_PP.xml"
EXEC_PATH="$(pwd)/hemelab-PP${VARIENT:+-${VARIENT}}/bin/hemepure"
ENV="$(pwd)/env.sh"
OUTPUT="results"

. "${ENV}"

cd "${CASE_PATH}"

echo "Job ID: $SLURM_JOB_ID"
echo "Job Name: $SLURM_JOB_NAME"
echo "Running on nodes: ${SLURM_NODELIST}"
echo "Allocated CPUs: $SLURM_CPUS_PER_TASK"
echo "Working directory: $(pwd)"
echo ""

if [ -d "${OUTPUT}" ]
then
	rm -rf "${OUTPUT}"
fi

# srun --mpi=pmi2 \
mpirun \
	"${EXEC_PATH}" \
	-in \
	"${CASE_NAME}" \
	-out \
	"${OUTPUT}"

echo "--- Finished Job ---"
