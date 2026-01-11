#!/bin/bash
#SBATCH --job-name hemegpu-test
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=4
#SBATCH --output=log/%x.%j.out
#SBATCH --error=log/%x.%j.err
#SBATCH --time=00:15:00
#SBATCH --gpus-per-node=8

set -e

VARIENT="PP"
# CASE_PATH="$(pwd)/cases/SixBranch_3inlet"
CASE_PATH="$(pwd)/Bifurcation-TINY"
CASE_NAME="input_PP.xml"
EXEC_PATH="$(pwd)/hemelabgpu${VARIENT:+-${VARIENT}}/bin/hemepure_gpu"
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

# export OMP_STACKSIZE=64M
# export CUDA_LAUNCH_BLOCKING=1

export CUDA_INJECTION64_PATH=none
export CUDA_DBG_ATTENTION_ON_BREAK=0

# export CUDA_GRAPH_DISABLE=1

export UCX_IB_GDR_COPY=n
export UCX_TLS=^cuda_gdrcopy,gdr_copy

# srun --mpi=pmi2 \
mpirun \
	"${EXEC_PATH}" \
	-in \
	"${CASE_NAME}" \
	-out \
	"${OUTPUT}"

echo "--- Finished Job ---"
