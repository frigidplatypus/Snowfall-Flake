{ pkgs, ... }:

pkgs.writers.writePython3Bin "wake" { libraries = [ pkgs.python312Packages.wakeonlan ]; } ''
  import sys
  from wakeonlan import send_magic_packet

  # Dictionary to store MAC addresses
  mac_addresses = {
      "nasnix": "10:60:4b:60:2e:3d",
      "p5810": "98:90:96:9c:93:e1",
  }


  def print_usage():
      """Function to print usage"""
      print("Usage: {} <hostname>".format(sys.argv[0]))
      sys.exit(1)


  def get_mac_address(hostname):
      """Function to get the MAC address for a given hostname"""
      return mac_addresses.get(hostname)


  def wake_machine(mac_address):
      """Function to wake the machine using the MAC address"""
      send_magic_packet(mac_address)


  def main():
      """Main script execution"""
      if len(sys.argv) != 2:
          print_usage()

      hostname = sys.argv[1]
      mac_address = get_mac_address(hostname)

      if not mac_address:
          print("MAC address not found for hostname: {}".format(hostname))
          sys.exit(1)

      wake_machine(mac_address)


  if __name__ == "__main__":
      main()
''
