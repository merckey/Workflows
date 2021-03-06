#!/bin/bash
#SBATCH --account=hci-rw
#SBATCH --partition=hci-rw
#SBATCH -N 1
#SBATCH -t 48:00:00

set -e; rm -f FAILED COMPLETE QUEUED; touch STARTED

# 6 November 2018
# David.Nix@Hci.Utah.Edu
# Huntsman Cancer Institute

# This tumor capture panel workflow uses Lofreq and Illumina's Manta/Strelka2 variant callers to identify short INDELs and SNVs. It uses a high depth NA12878 bam file in place of a matched normal.  
# A tuned set of filtering statistics is applied to produce lists with different FDR tiers. 
# A panel of normals is used to remove systematic false positives due to high localized background. Lastly, a prior call frequency is calculated for each variant to identify call artifacts.

#### Do just once ####

# 1) Install udocker in your home directory as yourself, not as root, https://github.com/indigo-dc/udocker/releases . Define the location of the udocker executable.
udocker=/uufs/chpc.utah.edu/common/HIPAA/u0028003/BioApps/UDocker/udocker-1.1.1/udocker

# 2) Define two mount file paths to expose in udocker. The first is to the TNRunner data bundle downloaded and uncompressed from https://hci-bio-app.hci.utah.edu/gnomex/gnomexFlex.jsp?analysisNumber=A5578 . The second is the path to your data.
dataBundle=/uufs/chpc.utah.edu/common/PE/hci-bioinformatics1/TNRunner
myData=/scratch/mammoth/serial/u0028003

# 3) Modify the workflow xxx.udocker file setting the paths to the required resources. These must be within the mounts.

# 4) Build the udocker container, do just once after each update.
## $udocker rm SnakeMakeBioApps_3 && $udocker pull hcibioinformatics/public:SnakeMakeBioApps_3 && $udocker create --name=SnakeMakeBioApps_3  hcibioinformatics/public:SnakeMakeBioApps_3 && echo "UDocker Container Built"


#### Do for every run ####

# 1) Create a folder named as you would like the analysis name to appear, this along with the genome build will be prepended onto all files, no spaces, change into it. This must reside somewhere in the myData mount path.

# 2) Soft link or move in the tumor bam and bai files.

# 3) Copy over the workflow docs: xxx.udocker, xxx.README.sh, and xxx.sm into the job directory.

# 4) Launch the xxx.README.sh via sbatch or run it on your local server.  

# 5) If the run fails, fix the issue and restart.  Snakemake should pick up where it left off.



#### No need to modify anything below ####

start=$(date +'%s')
echo -e "\n---------- Starting -------- $((($(date +'%s') - $start)/60)) min"

# Read out params
name=${PWD##*/}
tumorBam=`readlink -f *.bam`
jobDir=`readlink -f .`

echo -e "\n---------- Launching Container -------- $((($(date +'%s') - $start)/60)) min"
$udocker run \
--env=tumorBam=$tumorBam --env=name=$name --env=jobDir=$jobDir \
--volume=$dataBundle:$dataBundle --volume=$myData:$myData \
SnakeMakeBioApps_3 < *.udocker

echo -e "\n---------- Complete! -------- $((($(date +'%s') - $start)/60)) min total"

# Final cleanup
mkdir -p RunScripts
mv somTumorCaller* RunScripts/
mv *_SnakemakeRun.log Logs/
mv slurm* Logs/
rm -rf .snakemake
rm -f FAILED STARTED; touch COMPLETE



