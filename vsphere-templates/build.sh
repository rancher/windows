#!/usr/bin/env bash

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

set -e

follow_link() {
  FILE="$1"
  while [ -h "$FILE" ]; do
    # On Mac OS, readlink -f doesn't work.
    FILE="$(readlink "$FILE")"
  done
  echo "$FILE"
}

SCRIPT_PATH=$(realpath "$(dirname "$(follow_link "$0")")")
CONFIG_PATH=$(realpath "${1:-${SCRIPT_PATH}/config}")

menu_option_1() {
  INPUT_PATH="$SCRIPT_PATH"/builds/windows/server/2022/
  echo -e "\nCONFIRM: Build all Windows Server 2022 Templates for VMware vSphere?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  echo "Do you want to provide a custom name prefix for this template? This can be helpful for creating debug templates."
  echo "By default all templates use the format of '[prefix-][OSType]-[Year]-[Edition]-v[Year].[Month]'"
  echo "(e.g. windows-server-2022-standard-core-v24.12)"
  echo "Continue? (y/n)"
  read -r REPLY
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "Enter a custom name prefix for this template: "
    read -r CUSTOM_NAME
    if [[ -z $CUSTOM_NAME ]]; then
        echo "Must provide a custom name"
        exit 1
    fi
  fi

  ### Build all Windows Server 2022 Templates for VMware vSphere. ###
  echo "Building all Windows Server 2022 Templates for VMware vSphere..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  packer build -force \
      -var-file="$CONFIG_PATH/vsphere.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var="custom_template_prefix=$CUSTOM_NAME" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_2() {
  INPUT_PATH="$SCRIPT_PATH"/builds/windows/server/2022/
  echo -e "\nCONFIRM: Build Microsoft Windows Server 2022 Standard Templates for VMware vSphere?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  echo "Do you want to provide a custom name prefix for this template? This can be helpful for creating debug templates."
  echo "By default all templates use the format of '[prefix-][OSType]-[Year]-[Edition]-v[Year].[Month]'"
  echo "(e.g. windows-server-2022-standard-core-v24.12)"
  echo "Continue? (y/n)"
  read -r REPLY
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "Enter a custom name prefix for this template: "
    read -r CUSTOM_NAME
    if [[ -z $CUSTOM_NAME ]]; then
        echo "Must provide a custom name"
        exit 1
    fi
  fi

  ### Build Microsoft Windows Server 2022 Standard Templates for VMware vSphere. ###
  echo "Building Microsoft Windows Server 2022 Standard Templates for VMware vSphere..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  packer build -force \
      --only vsphere-iso.windows-server-standard-dexp,vsphere-iso.windows-server-standard-core \
      -var-file="$CONFIG_PATH/vsphere.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var="custom_template_prefix=$CUSTOM_NAME" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_3() {
  INPUT_PATH="$SCRIPT_PATH"/builds/windows/server/2022/
  echo -e "\nCONFIRM: Build Microsoft Windows Server 2022 Standard Core Template for VMware vSphere?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  echo "Do you want to provide a custom name prefix for this template? This can be helpful for creating debug templates."
  echo "By default all templates use the format of '[prefix-][OSType]-[Year]-[Edition]-v[Year].[Month]'"
  echo "(e.g. windows-server-2022-standard-core-v24.12)"
  echo "Continue? (y/n)"
  read -r REPLY
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "Enter a custom name prefix for this template: "
    read -r CUSTOM_NAME
    if [[ -z $CUSTOM_NAME ]]; then
        echo "Must provide a custom name"
        exit 1
    fi
  fi

  ### Build Microsoft Windows Server 2022 Standard Core Template for VMware vSphere. ###
  echo "Building Microsoft Windows Server 2022 Standard Core Template for VMware vSphere..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  packer build -force \
      --only vsphere-iso.windows-server-standard-core \
      -var-file="$CONFIG_PATH/vsphere.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var="custom_template_prefix=$CUSTOM_NAME" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_4() {
  INPUT_PATH="$SCRIPT_PATH"/builds/windows/server/2022/
  echo -e "\nCONFIRM: Build Microsoft Windows Server 2022 Standard Desktop Template for VMware vSphere?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  echo "Do you want to provide a custom name prefix for this template? This can be helpful for creating debug templates."
  echo "By default all templates use the format of '[prefix-][OSType]-[Year]-[Edition]-v[Year].[Month]'"
  echo "(e.g. windows-server-2022-standard-core-v24.12)"
  echo "Continue? (y/n)"
  read -r REPLY
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "Enter a custom name prefix for this template: "
    read -r CUSTOM_NAME
    if [[ -z $CUSTOM_NAME ]]; then
        echo "Must provide a custom name"
        exit 1
    fi
  fi

  ### Build Microsoft Windows Server 2022 Standard Desktop Template for VMware vSphere. ###
  echo "Building Microsoft Windows Server 2022 Standard Desktop Template for VMware vSphere..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  packer build -force \
      --only vsphere-iso.windows-server-standard-dexp \
      -var-file="$CONFIG_PATH/vsphere.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var="custom_template_prefix=$CUSTOM_NAME" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_5() {
  INPUT_PATH="$SCRIPT_PATH"/builds/windows/server/2022/
  echo -e "\nCONFIRM: Build Microsoft Windows Server 2022 Datacenter Templates for VMware vSphere?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  echo "Do you want to provide a custom name prefix for this template? This can be helpful for creating debug templates."
  echo "By default all templates use the format of '[prefix-][OSType]-[Year]-[Edition]-v[Year].[Month]'"
  echo "(e.g. windows-server-2022-standard-core-v24.12)"
  echo "Continue? (y/n)"
  read -r REPLY
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "Enter a custom name prefix for this template: "
    read -r CUSTOM_NAME
    if [[ -z $CUSTOM_NAME ]]; then
        echo "Must provide a custom name"
        exit 1
    fi
  fi

  ### Build Microsoft Windows Server 2022 Datacenter Templates for VMware vSphere. ###
  echo "Building Microsoft Windows Server 2022 Datacenter Templates for VMware vSphere..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  packer build -force \
      --only vsphere-iso.windows-server-datacenter-dexp,vsphere-iso.windows-server-datacenter-core \
      -var-file="$CONFIG_PATH/vsphere.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var="custom_template_prefix=$CUSTOM_NAME" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_6() {
  INPUT_PATH="$SCRIPT_PATH"/builds/windows/server/2022/
  echo -e "\nCONFIRM: Build Microsoft Windows Server 2022 Datacenter Templates for VMware vSphere?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  echo "Do you want to provide a custom name prefix for this template? This can be helpful for creating debug templates."
  echo "By default all templates use the format of '[prefix-][OSType]-[Year]-[Edition]-v[Year].[Month]'"
  echo "(e.g. windows-server-2022-standard-core-v24.12)"
  echo "Continue? (y/n)"
  read -r REPLY
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "Enter a custom name prefix for this template: "
    read -r CUSTOM_NAME
    if [[ -z $CUSTOM_NAME ]]; then
        echo "Must provide a custom name"
        exit 1
    fi
  fi

  ### Build Microsoft Windows Server 2022 Datacenter Templates for VMware vSphere. ###
  echo "Building Microsoft Windows Server 2022 Datacenter Templates for VMware vSphere..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  packer build -force \
      --only vsphere-iso.windows-server-datacenter-core \
      -var-file="$CONFIG_PATH/vsphere.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var="custom_template_prefix=$CUSTOM_NAME" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_7() {
  INPUT_PATH="$SCRIPT_PATH"/builds/windows/server/2022/
  echo -e "\nCONFIRM: Build Microsoft Windows Server 2022 Datacenter Templates for VMware vSphere?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  echo "Do you want to provide a custom name prefix for this template? This can be helpful for creating debug templates."
  echo "By default all templates use the format of '[prefix-][OSType]-[Year]-[Edition]-v[Year].[Month]'"
  echo "(e.g. windows-server-2022-standard-core-v24.12)"
  echo "Continue? (y/n)"
  read -r REPLY
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "Enter a custom name prefix for this template: "
    read -r CUSTOM_NAME
    if [[ -z $CUSTOM_NAME ]]; then
        echo "Must provide a custom name"
        exit 1
    fi
  fi

  ### Build Microsoft Windows Server 2022 Datacenter Templates for VMware vSphere. ###
  echo "Building Microsoft Windows Server 2022 Datacenter Templates for VMware vSphere..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  packer build -force \
      --only vsphere-iso.windows-server-datacenter-dexp,vsphere-iso.windows-server-datacenter-core \
      -var-file="$CONFIG_PATH/vsphere.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var="custom_template_prefix=$CUSTOM_NAME" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_8() {
  INPUT_PATH="$SCRIPT_PATH"/builds/windows/server/2019/
  echo -e "\nCONFIRM: Build all Windows Server 2019 Templates for VMware vSphere?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  echo "Do you want to provide a custom name prefix for this template? This can be helpful for creating debug templates."
  echo "By default all templates use the format of '[prefix-][OSType]-[Year]-[Edition]-v[Year].[Month]'"
  echo "(e.g. windows-server-2022-standard-core-v24.12)"
  echo "Continue? (y/n)"
  read -r REPLY
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "Enter a custom name prefix for this template: "
    read -r CUSTOM_NAME
    if [[ -z $CUSTOM_NAME ]]; then
        echo "Must provide a custom name"
        exit 1
    fi
  fi

  ### Build all Windows Server 2019 Templates for VMware vSphere. ###
  echo "Building all Windows Server 2019 Templates for VMware vSphere..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  packer build -force \
      -var-file="$CONFIG_PATH/vsphere.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var="custom_template_prefix=$CUSTOM_NAME" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_9() {
  INPUT_PATH="$SCRIPT_PATH"/builds/windows/server/2019/
  echo -e "\nCONFIRM: Build Microsoft Windows Server 2019 Standard Templates for VMware vSphere?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  echo "Do you want to provide a custom name prefix for this template? This can be helpful for creating debug templates."
  echo "By default all templates use the format of '[prefix-][OSType]-[Year]-[Edition]-v[Year].[Month]'"
  echo "(e.g. windows-server-2022-standard-core-v24.12)"
  echo "Continue? (y/n)"
  read -r REPLY
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "Enter a custom name prefix for this template: "
    read -r CUSTOM_NAME
    if [[ -z $CUSTOM_NAME ]]; then
        echo "Must provide a custom name"
        exit 1
    fi
  fi

  ### Build Microsoft Windows Server 2019 Standard Templates for VMware vSphere. ###
  echo "Building Microsoft Windows Server 2019 Standard Templates for VMware vSphere..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  packer build -force \
      --only vsphere-iso.windows-server-standard-dexp,vsphere-iso.windows-server-standard-core \
      -var-file="$CONFIG_PATH/vsphere.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var="custom_template_prefix=$CUSTOM_NAME" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_10() {
  INPUT_PATH="$SCRIPT_PATH"/builds/windows/server/2019/
  echo -e "\nCONFIRM: Build Microsoft Windows Server 2019 Standard Core Template for VMware vSphere?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  echo "Do you want to provide a custom name prefix for this template? This can be helpful for creating debug templates."
  echo "By default all templates use the format of '[prefix-][OSType]-[Year]-[Edition]-v[Year].[Month]'"
  echo "(e.g. windows-server-2022-standard-core-v24.12)"
  echo "Continue? (y/n)"
  read -r REPLY
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "Enter a custom name prefix for this template: "
    read -r CUSTOM_NAME
    if [[ -z $CUSTOM_NAME ]]; then
        echo "Must provide a custom name"
        exit 1
    fi
  fi

  ### Build Microsoft Windows Server 2019 Standard Core Template for VMware vSphere. ###
  echo "Building Microsoft Windows Server 2019 Standard Core Template for VMware vSphere..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  packer build -force \
      --only vsphere-iso.windows-server-standard-core \
      -var-file="$CONFIG_PATH/vsphere.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var="custom_template_prefix=$CUSTOM_NAME" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_11() {
  INPUT_PATH="$SCRIPT_PATH"/builds/windows/server/2019/
  echo -e "\nCONFIRM: Build Microsoft Windows Server 2019 Standard Desktop Template for VMware vSphere?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  echo "Do you want to provide a custom name prefix for this template? This can be helpful for creating debug templates."
  echo "By default all templates use the format of '[prefix-][OSType]-[Year]-[Edition]-v[Year].[Month]'"
  echo "(e.g. windows-server-2022-standard-core-v24.12)"
  echo "Continue? (y/n)"
  read -r REPLY
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "Enter a custom name prefix for this template: "
    read -r CUSTOM_NAME
    if [[ -z $CUSTOM_NAME ]]; then
        echo "Must provide a custom name"
        exit 1
    fi
  fi

  ### Build Microsoft Windows Server 2019 Standard Desktop Template for VMware vSphere. ###
  echo "Building Microsoft Windows Server 2019 Standard Desktop Template for VMware vSphere..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  packer build -force \
      --only vsphere-iso.windows-server-standard-dexp \
      -var-file="$CONFIG_PATH/vsphere.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var="custom_template_prefix=$CUSTOM_NAME" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_12() {
  INPUT_PATH="$SCRIPT_PATH"/builds/windows/server/2019/
  echo -e "\nCONFIRM: Build Microsoft Windows Server 2019 Datacenter Templates for VMware vSphere?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  echo "Do you want to provide a custom name prefix for this template? This can be helpful for creating debug templates."
  echo "By default all templates use the format of '[prefix-][OSType]-[Year]-[Edition]-v[Year].[Month]'"
  echo "(e.g. windows-server-2022-standard-core-v24.12)"
  echo "Continue? (y/n)"
  read -r REPLY
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "Enter a custom name prefix for this template: "
    read -r CUSTOM_NAME
    if [[ -z $CUSTOM_NAME ]]; then
        echo "Must provide a custom name"
        exit 1
    fi
  fi

  ### Build Microsoft Windows Server 2019 Datacenter Templates for VMware vSphere. ###
  echo "Building Microsoft Windows Server 2019 Datacenter Templates for VMware vSphere..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  packer build -force \
      --only vsphere-iso.windows-server-datacenter-dexp,vsphere-iso.windows-server-datacenter-core \
      -var-file="$CONFIG_PATH/vsphere.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var="custom_template_prefix=$CUSTOM_NAME" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_13() {
  INPUT_PATH="$SCRIPT_PATH"/builds/windows/server/2019/
  echo -e "\nCONFIRM: Build Microsoft Windows Server 2019 Datacenter Core Template for VMware vSphere?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  echo "Do you want to provide a custom name prefix for this template? This can be helpful for creating debug templates."
  echo "By default all templates use the format of '[prefix-][OSType]-[Year]-[Edition]-v[Year].[Month]'"
  echo "(e.g. windows-server-2022-standard-core-v24.12)"
  echo "Continue? (y/n)"
  read -r REPLY
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "Enter a custom name prefix for this template: "
    read -r CUSTOM_NAME
    if [[ -z $CUSTOM_NAME ]]; then
        echo "Must provide a custom name"
        exit 1
    fi
  fi

  ### Build Microsoft Windows Server 2019 Datacenter Core Template for VMware vSphere. ###
  echo "Building Microsoft Windows Server 2019 Datacenter Core Template for VMware vSphere..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  packer build -force \
      --only vsphere-iso.windows-server-datacenter-core \
      -var-file="$CONFIG_PATH/vsphere.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var="custom_template_prefix=$CUSTOM_NAME" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_14() {
  INPUT_PATH="$SCRIPT_PATH"/builds/windows/server/2019/
  echo -e "\nCONFIRM: Build Microsoft Windows Server 2019 Datacenter Desktop Template for VMware vSphere?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  echo "Do you want to provide a custom name prefix for this template? This can be helpful for creating debug templates."
  echo "By default all templates use the format of '[prefix-][OSType]-[Year]-[Edition]-v[Year].[Month]'"
  echo "(e.g. windows-server-2022-standard-core-v24.12)"
  echo "Continue? (y/n)"
  read -r REPLY
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "Enter a custom name prefix for this template: "
    read -r CUSTOM_NAME
    if [[ -z $CUSTOM_NAME ]]; then
        echo "Must provide a custom name"
        exit 1
    fi
  fi

  ### Build Microsoft Windows Server 2019 Datacenter Desktop Template for VMware vSphere. ###
  echo "Building Microsoft Windows Server 2019 Datacenter Desktop Template for VMware vSphere..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  packer build -force \
      --only vsphere-iso.windows-server-datacenter-dexp \
      -var-file="$CONFIG_PATH/vsphere.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var="custom_template_prefix=$CUSTOM_NAME" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

press_enter() {
  cd "$SCRIPT_PATH"
  echo -n "Press Enter to continue."
  read -r
  clear
}

info() {
  echo "License: BSD-2"
  echo ""
  echo "For more information, review the project README."
  echo "GitHub Repository: github.com/vmware-samples/packer-examples-for-vsphere/"
  read -r
}

incorrect_selection() {
  echo "Invalid Input. Do or do not. There is no try."
}

until [ "$selection" = "0" ]; do
  clear
  echo ""
  echo "     ____                       __                    ____                __                 ____          _  __     __                                                                             "
  echo "    / __ \ ____ _ ____   _____ / /_   ___   _____    / __ \ ____ _ _____ / /__ ___   _____  / __ ) __  __ (_)/ /____/ /_____  "
  echo "   / /_/ // __  // __ \ / ___// __ \ / _ \ / ___/   / /_/ // __ // ___// // _// _ \ / ___/ / __  |/ / / // // // __  // ___/  "
  echo "  / _, _// /_/ // / / // /__ / / / //  __// /      / ____// /_/ // /__ / ,<  /  __// /    / /_/ // /_/ // // // /_/ /(__  )  "
  echo " /_/ |_| \__,_//_/ /_/ \___//_/ /_/ \___//_/      /_/     \__,_/ \___//_/|_| \___//_/    /_____/ \__,_//_//_/ \__,_//____/  "
  echo ""
  echo -n "  Select a HashiCorp Packer build for VMware vSphere:"
  echo ""
  echo ""
  echo "      Microsoft Windows:"
  echo ""
  echo "    	 1  -  Windows Server 2022 - All"
  echo "    	 2  -  Windows Server 2022 - Standard Only (Core And Desktop)"
  echo "    	 3  -  Windows Server 2022 - Standard Core Only"
  echo "    	 4  -  Windows Server 2022 - Standard Desktop Only"
  echo "    	 5  -  Windows Server 2022 - Datacenter Only (Core And Desktop)"
  echo "    	 6  -  Windows Server 2022 - Datacenter Core Only"
  echo "    	 7  -  Windows Server 2022 - Datacenter Desktop Only"
  echo "    	 8  -  Windows Server 2019 - All"
  echo "    	 9  -  Windows Server 2019 - Standard Only (Core And Desktop)"
  echo "    	10  -  Windows Server 2019 - Standard Core Only"
  echo "    	11  -  Windows Server 2019 - Standard Desktop Only"
  echo "    	12  -  Windows Server 2019 - Datacenter Only (Core And Desktop)"
  echo "    	13  -  Windows Server 2019 - Datacenter Core Only"
  echo "    	14  -  Windows Server 2019 - Datacenter Desktop Only"
  echo ""
  echo "      Other:"
  echo ""
  echo "        I   -  Information"
  echo "        Q   -  Quit"
  echo ""
  read -r selection
  echo ""
  case $selection in
    1 ) clear ; menu_option_1 ; press_enter ;;
    2 ) clear ; menu_option_2 ; press_enter ;;
    3 ) clear ; menu_option_3 ; press_enter ;;
    4 ) clear ; menu_option_4 ; press_enter ;;
    5 ) clear ; menu_option_5 ; press_enter ;;
    6 ) clear ; menu_option_6 ; press_enter ;;
    7 ) clear ; menu_option_7 ; press_enter ;;
    8 ) clear ; menu_option_8 ; press_enter ;;
    9 ) clear ; menu_option_9 ; press_enter ;;
    10 ) clear ; menu_option_10 ; press_enter ;;
    11 ) clear ; menu_option_11 ; press_enter ;;
    12 ) clear ; menu_option_12 ; press_enter ;;
    13 ) clear ; menu_option_13 ; press_enter ;;
    14 ) clear ; menu_option_14 ; press_enter ;;
    I ) clear ; info ; press_enter ;;
    Q ) clear ; exit ;;
    * ) clear ; incorrect_selection ; press_enter ;;
  esac
done
