#!/bin/bash
#SBATCH --account=hci-rw
#SBATCH --partition=hci-rw
#SBATCH -N 1
#SBATCH -t 96:00:00

set -e; start=$(date +'%s'); rm -f FAILED COMPLETE QUEUED; touch STARTED

# 23 January 2019
# David.Nix@Hci.Utah.Edu
# Huntsman Cancer Institute

# This is a standard GATK GenotypeGVCFs analysis followed by normalizing the vcf with vt and splitting it into individual vcf files with light filtering.


#### Do just once ####

# 1) Install Singularity (https://www.sylabs.io) or load via a module then define the path to the executable
module load singularity/3.0.1
singExec=/uufs/chpc.utah.edu/sys/installdir/singularity3/3.0.1/bin/singularity

# 2) Define file paths to "mount" in the container. The first is to the TNRunner data bundle downloaded and uncompressed from https://hci-bio-app.hci.utah.edu/gnomex/gnomexFlex.jsp?analysisNumber=A5578 . The second is the path to your data.
dataBundle=/uufs/chpc.utah.edu/common/PE/hci-bioinformatics1/TNRunner
myData=/uufs/chpc.utah.edu/common/HIPAA/u0028003/Scratch

# 3) Modify the workflow xxx.sing file setting the paths to the required resources. These must be within the mounts.

# 4) Build the singularity container, and define the path to the xxx.sif file, do just once after each update.
#$singExec pull docker://hcibioinformatics/public:SnakeMakeBioApps_4
container=/uufs/chpc.utah.edu/common/HIPAA/u0028003/HCINix/SingularityBuilds/public_SnakeMakeBioApps_4.sif


#### Do for every run ####

# 1) Create a folder named as you would like the analysis name to appear, this along with the genome build will be prepended onto all files, no spaces, change into it. This must reside somewhere in the myData mount path.

# 2) Create a folder named ToGenotype in the analysis folder.

# 2) Move or Soft link all the xxx.g.vcf.gz files into the ToGenotype folder from running the GATK Haplotype caller.

# 3) Copy over the JointGenotyping workflow docs: xxx.sing, xxx.README.sh, and xxx.sm into the analysis folder.

# 4) Launch the xxx.README.sh via sbatch or run it on your local server.  

# 5) If the run fails, fix the issue and restart.  Snakemake should pick up where it left off.



#### No need to modify anything below ####

echo -e "\n---------- Starting -------- $((($(date +'%s') - $start)/60)) min"

# Read out params 
name=${PWD##*/}
jobDir=`readlink -f .`

SINGULARITYENV_name=$name SINGULARITYENV_jobDir=$jobDir SINGULARITYENV_dataBundle=$dataBundle \
$singExec exec --containall --bind $dataBundle,$myData $container \
bash $jobDir/*.sing

echo -e "\n---------- Complete! -------- $((($(date +'%s') - $start)/60)) min total"

# Final cleanup
mkdir -p RunScripts
mv jointGenotyping* RunScripts/
mv -f *.log  Logs/ || true
mv -f slurm* Logs/ || true
rm -rf .snakemake 
rm -f FAILED STARTED DONE RESTART
touch COMPLETE 


