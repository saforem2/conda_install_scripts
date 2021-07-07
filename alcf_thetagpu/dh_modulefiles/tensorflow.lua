help([[
The Anaconda python environment.
Includes build of TensorFlow, PyTorch, DeepHyper from tagged versions of the git repos
DeepHyper version tag: 0.2.5
TensorFlow version tag: 2.4.2
Horovod version tag: 0.21.3
PyTorch version tag: 1.9.0a0+gitd69c22d
- DDP with NCCL (2.9.9-1+cuda11.3, built by Adam Scovel) works in this module

You can modify this environment as follows:

  - Extend this environment locally

      $ pip install --user [package]

  - Create a new one of your own

      $ conda create -n [environment_name] [package]

https://docs.conda.io/projects/conda/en/latest/user-guide/getting-started.html
]])

whatis("Name: conda")
whatis("Version: 4.10.1")
whatis("Category: python conda")
whatis("Keywords: python conda")
whatis("Description: Base Anaconda python environment")
whatis("URL: https://docs.conda.io/projects/conda/en/latest/user-guide/getting-started.html")

depends_on("openmpi/openmpi-4.0.5")


local conda_dir = "/lus/theta-fs0/software/thetagpu/conda/2021-06-26/mconda3"
local funcs = "conda __conda_activate __conda_hashr __conda_reactivate __add_sys_prefix_to_path"

-- Specify where system and user environments should be created
-- setenv("CONDA_ENVS_PATH", pathJoin(conda_dir,"envs"))
-- Directories are separated with a comma
-- setenv("CONDA_PKGS_DIRS", pathJoin(conda_dir,"pkgs"))
-- set environment name for prompt tag
setenv("ENV_NAME",myModuleFullName())
setenv("PYTHONUSERBASE",pathJoin("$HOME/.local",myModuleFullName()))
setenv("PYTHONSTARTUP",pathJoin(conda_dir,"etc/pythonstart"))

-- add cuda libraries
prepend_path("LD_LIBRARY_PATH","/usr/local/cuda-11.3/lib64")
prepend_path("LD_LIBRARY_PATH","/lus/theta-fs0/software/thetagpu/cuda/cudnn-11.3-linux-x64-v8.2.0.53/lib64")
prepend_path("PATH","/lus/theta-fs0/software/thetagpu/nccl/nccl-v2.9.9-1_gcc-9.3.0-17ubuntu1-20.04/include")
prepend_path("LD_LIBRARY_PATH","/lus/theta-fs0/software/thetagpu/nccl/nccl-v2.9.9-1_gcc-9.3.0-17ubuntu1-20.04/lib")
prepend_path("LD_LIBRARY_PATH","/lus/theta-fs0/software/thetagpu/cuda/TensorRT-7.2.3.4.Ubuntu-18.04.x86_64-gnu.cuda-11.1.cudnn8.1/lib")

setenv("https_proxy","http://proxy.tmi.alcf.anl.gov:3128")
setenv("http_proxy","http://proxy.tmi.alcf.anl.gov:3128")

-- Initialize conda
execute{cmd="source " .. conda_dir .. "/etc/profile.d/conda.sh;", modeA={"load"}}
execute{cmd="[[ -z ${ZSH_EVAL_CONTEXT} ]] && export -f " .. funcs, modeA={"load"}}
-- Unload environments and clear conda from environment
execute{cmd="for i in $(seq ${CONDA_SHLVL:=0}); do conda deactivate; done; pre=" .. conda_dir .. "; \
	export LD_LIBRARY_PATH=$(echo ${LD_LIBRARY_PATH} | tr ':' '\\n' | grep . | grep -v $pre | tr '\\n' ':' | sed 's/:$//'); \
	export PATH=$(echo ${PATH} | tr ':' '\\n' | grep . | grep -v $pre | tr '\\n' ':' | sed 's/:$//'); \
	unset -f " .. funcs .. "; \
	unset $(env | grep -o \"[^=]*CONDA[^=]*\");", modeA={"unload"}}

-- Prevent from being loaded with another system python or conda environment
family("python")
