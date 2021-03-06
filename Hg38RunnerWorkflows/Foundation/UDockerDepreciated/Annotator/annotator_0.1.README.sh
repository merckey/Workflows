#!/bin/bash
#SBATCH --account=hci-rw
#SBATCH --partition=hci-rw
#SBATCH -N 1
#SBATCH -t 48:00:00

set -e; start=$(date +'%s'); rm -f FAILED COMPLETE QUEUED; touch STARTED

# 14 September 2018
# David.Nix@Hci.Utah.Edu
# Huntsman Cancer Institute

# This fires a variety of apps that annotate a vcf with functional effect info using SnpEff, dbNSFP, ClinVar, and the VCFSpliceScanner.  It also generates a filtered vcf based on these annotations.



#### Do just once ####

# 1) Install udocker in your home directory as yourself, not as root, https://github.com/indigo-dc/udocker/releases . Define the location of the udocker executable.
udocker=/uufs/chpc.utah.edu/common/HIPAA/u0028003/BioApps/UDocker/udocker-1.1.1/udocker

# 2) Define two mount file paths to expose in udocker. The first is to the TNRunner data bundle downloaded and uncompressed from https://hci-bio-app.hci.utah.edu/gnomex/gnomexFlex.jsp?analysisNumber=A5578 . The second is the path to your data.
dataBundle=/uufs/chpc.utah.edu/common/PE/hci-bioinformatics1/TNRunner
myData=/scratch/mammoth/serial/u0028003

# 3) Modify the Annotator workflow xxx.udocker file setting the paths to the required resources. These must be within the mounts.

# 4) Create a file called annotatedVcfParser.config.txt and provide params for the USeq AnnotatedVcfParser application, e.g. '-d 10 -m 0.2 -x 1 -p 0.01 -g D5S,D3S -n 5 -a HIGH -c Pathogenic,Likely_pathogenic -o -e Benign,Likely_benign' for germline or '-d 20 -f' for somatic.

# 5) Build the udocker container, do just once after each update.
## $udocker rm SnakeMakeBioApps_3 && $udocker pull hcibioinformatics/public:SnakeMakeBioApps_3 && $udocker create --name=SnakeMakeBioApps_3  hcibioinformatics/public:SnakeMakeBioApps_3 && echo "UDocker Container Built"



#### Do for every run ####

# 1) Create a folder named as you would like the analysis name to appear, this along with the genome build will be prepended onto all files, no spaces, change into it. This must reside somewhere in the myData mount path.

# 2) Copy or soft link your gzipped vcf file to annotate into the job directory naming it anything ending in .vcf.gz

# 3) Copy over the Annotator workflow docs: xxx.udocker, xxx.README.sh, and xxx.sm as well as the annotatedVcfParser.config.txt into the job directory.

# 4) Launch the xxx.README.sh via sbatch or run it on your local server.  

# 5) If the run fails, fix the issue and restart.  Snakemake should pick up where it left off.



#### No need to modify anything below ####
echo -e "\n---------- Starting -------- $((($(date +'%s') - $start)/60)) min"

# Read out params and fetch real path for linked fastq
name=${PWD##*/}
jobDir=`readlink -f .`

$udocker run --env=name=$name --env=jobDir=$jobDir \
--volume=$dataBundle:$dataBundle --volume=$myData:$myData \
SnakeMakeBioApps_3 < annotator_*.udocker

echo -e "\n---------- Complete! -------- $((($(date +'%s') - $start)/60)) min total"

# Final cleanup
mkdir -p RunScripts
mv annotator_* RunScripts/
mv *.log Logs/
mv snpEff_* Logs/
rm -rf .snakemake 
mv -f slurm* Logs/
rm -f FAILED STARTED; touch COMPLETE

