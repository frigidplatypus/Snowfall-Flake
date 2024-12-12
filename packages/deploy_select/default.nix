{ pkgs, ... }:
pkgs.writeShellScriptBin "deploy_select" ''

  pushd $FLAKE || exit
  OUTPUT_FILE="$FLAKE/.outputs.txt"

  # Function to fetch and save outputs
  fetch_outputs() {
    echo "Fetching the list of x86_64-linux system outputs..."
    outputs=$(nix flake show --json 2>/dev/null | jq -r '.nixosConfigurations | keys[]')
    outputs=$(printf "All\n%s" "$outputs")
    echo "$outputs" > "$OUTPUT_FILE"
    echo "Outputs saved to $OUTPUT_FILE"
  }

  # Function to read outputs from file if it exists, otherwise fetch and save
  read_or_fetch_outputs() {
    if [ -f "$OUTPUT_FILE" ]; then
      echo "Reading outputs from $OUTPUT_FILE..."
      outputs=$(cat "$OUTPUT_FILE")
    else
      fetch_outputs
      outputs=$(cat "$OUTPUT_FILE")
    fi
    echo "Available options:"
    echo "$outputs"
  }

  # Function to prompt user to choose a system or 'All'
  prompt_user_selection() {
    echo "Prompting user to choose a system or 'All'..."
    selected_output=$(echo "$outputs" | gum filter --limit=1 --header="Choose ALL or a SYSTEM")
  }

  # Function to check if the selected output is valid
  # Function to check if the selected output is valid
  validate_selection() {
    if ! echo "$outputs" | grep -q "^$selected_output$"; then
      if [ -d "systems/x86_64-linux/$selected_output" ]; then
        if git ls-files --error-unmatch "systems/x86_64-linux/$selected_output/default.nix" > /dev/null 2>&1; then
          echo "Found folder and default.nix for $selected_output in systems/x86_64-linux"
        else
          echo "Folder exists but no default.nix found in git for $selected_output"
          exit 1
        fi
      else
        echo "Invalid target: $selected_output"
        exit 1
      fi
    fi
  }

  # Function to deploy to the selected system or all systems
  deploy_system() {
    if [ "$selected_output" = "All" ]; then
      echo "Deploying to all systems..."
      pushd "$FLAKE" || exit
      deploy
      popd || exit
    else
      if [ "$HOSTNAME" = "$selected_output" ]; then
        echo "Hostname matches an output. Using 'nh os switch' command."
        nh os switch
      else
        echo "Deploying to $selected_output..."
        pushd "$FLAKE" || exit
        deploy
        popd || exit
      fi
      echo "Deploying to $selected_output..."
      echo
      pushd "$FLAKE" || exit
      deploy ".#$selected_output"
      popd || exit
    fi
    echo "Deployment script finished."
  }

  # Initialize variables
  selected_output=""

  # Parse command line arguments
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --update)
        fetch_outputs
        shift
        ;;
      -t | --target)
        selected_output="$2"
        shift 2
        ;;
      -l | --local)
        nh os switch
        exit 0
        ;;
      *)
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
  done

  # Read outputs from file if it exists, otherwise fetch and save
  if [ -z "$selected_output" ]; then
    read_or_fetch_outputs
    prompt_user_selection
  fi

  # Check if the selected output is valid
  validate_selection

  # Print the selected output
  echo "You selected: $selected_output"

  # Confirm deployment
  if gum confirm "Do you want to proceed with the deployment?"; then
    deploy_system
  else
    echo "Deployment canceled."
  fi
''
