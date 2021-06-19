#!/bin/sh

ncs_revision="v1.5.0"

cd ${HOME}
sudo rm -r ncs gn gnuarmemb
sudo apt-get update && sudo apt-get upgrade -y
sudo apt --fix-broken install -y

#echo "----------------安装GN工具----------------"
sudo apt install --no-install-recommends git cmake ninja-build gperf \
  ccache dfu-util device-tree-compiler wget \
  python3-dev python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
  make gcc gcc-multilib g++-multilib libsdl2-dev
mkdir ${HOME}/gn && cd ${HOME}/gn
wget -O gn.zip https://chrome-infra-packages.appspot.com/dl/gn/gn/linux-amd64/+/latest
unzip gn.zip
rm gn.zip
echo 'export PATH=${HOME}/gn:"$PATH"' >> ${HOME}/.bashrc
source ${HOME}/.bashrc

#echo "----------------安装west----------------"
pip3 install --user west
echo 'export PATH=~/.local/bin:"$PATH"' >> ~/.bashrc
source ~/.bashrc


#echo "-------获取nRF Connect SDK代码-------"
mkdir ${HOME}/ncs && cd ${HOME}/ncs
west init -m https://github.com/nrfconnect/sdk-nrf --mr $ncs_revision
west update
west zephyr-export

pip3 install --user -r zephyr/scripts/requirements.txt

cat nrf/scripts/requirements-doc.txt
sed -i '$d' nrf/scripts/requirements-doc.txt
cat nrf/scripts/requirements-doc.txt
pip3 install --user -r nrf/scripts/requirements.txt

pip3 install --user -r bootloader/mcuboot/scripts/requirements.txt

#echo "-------安装编译工具链------"
cd ${HOME}
wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/10-2020q4/gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2
tar -xvf gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2
mv gcc-arm-none-eabi-10-2020-q4-major gnuarmemb 
rm gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2
export ZEPHYR_TOOLCHAIN_VARIANT=gnuarmemb
export GNUARMEMB_TOOLCHAIN_PATH="~/gnuarmemb"


#echo "-------安装nRF命令行工具，主要用于程序烧写------"
cd ${HOME}
wget https://www.nordicsemi.com/-/media/Software-and-other-downloads/Desktop-software/nRF-command-line-tools/sw/Versions-10-x-x/10-12-1/nRFCommandLineTools10121Linuxamd64.tar.gz
mkdir nrfjprog
tar -xvf nRFCommandLineTools10121Linuxamd64.tar.gz -C nrfjprog
cd nrfjprog
#sudo dpkg -i --force-overwrite JLink_Linux_V688a_x86_64.deb
sudo apt-get install jlink
sudo dpkg -i --force-overwrite nRF-Command-Line-Tools_10_12_1_Linux-amd64.deb
cd ..
rm -r nrfjprog
rm nRFCommandLineTools10121Linuxamd64.tar.gz

#echo "-------配置命令行环境变量------"
cd ${HOME}
sudo touch .zephyrrc
echo 'export ZEPHYR_TOOLCHAIN_VARIANT=gnuarmemb' >> .zephyrrc
echo 'export GNUARMEMB_TOOLCHAIN_PATH="~/gnuarmemb"' >> .zephyrrc

#echo "-------打开NCS文件夹------"
# cat ~/.bashrc
# echo 'source ~/ncs/zephyr/zephyr-env.sh' >> ~/.bashrc
# echo 'echo "------------------------------ncs env is ready!------------------------------"' >> ~/.bashrc
# cat ~/.bashrc
cd ${HOME}/ncs