#!/bin/bash
#SBATCH --job-name=hemepure_test
#SBATCH --output=out_%j.log
#SBATCH --error=err_%j.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --time=00:10:00
#SBATCH --partition=normal
#SBATCH --account=ACD114124
#SBATCH --gpus-per-node=1

# Environment Setup
module purge
module load gcc/11.5.0
module load openmpi/4.1.6
module load cmake/3.24.2

# Define Paths
SUBMIT_DIR="$SLURM_SUBMIT_DIR"
PROJECT_ROOT="$SUBMIT_DIR/../.."

# Ensure custom libraries are found
export LD_LIBRARY_PATH="$PROJECT_ROOT/dep/install/lib:$LD_LIBRARY_PATH"

EXE="$SUBMIT_DIR/hemepure"
CASE_DIR="$PROJECT_ROOT/cases/pipe"

# Pre-flight Checks
if [ ! -f "$EXE" ]; then
    echo "Error: Executable $EXE not found."
    exit 1
fi

if [ ! -d "$CASE_DIR" ]; then
    echo "Error: Case directory $CASE_DIR not found."
    exit 1
fi

# Execution
echo "Job started at $(date)"
echo "Running on node: $(hostname)"
echo "Library Path: $LD_LIBRARY_PATH"

# Change to case directory
cd "$CASE_DIR"
rm -rf results

# 1. Print help first (in case we need to debug arguments later)
"$EXE" --help
echo "----------------------------------------"
echo "Starting Simulation..."

# 2. Run with corrected flags (-in instead of -c)
# Note: Using mpirun as previously determined
mpirun -np $SLURM_NTASKS "$EXE" -in input.xml -out results

echo "Job finished at $(date)"