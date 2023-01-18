POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--device)
      DEVICE="$2"
      shift # past argument
      shift # past value
      ;;
    -n|--network)
      NETWORK="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--h)
      echo "usage: -d|--device [device] -n|--network [network]"
      exit 0 
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=('$1') # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if [ -z "${NETWORK}" ]; then
  NETWORK=10
  DEFAULT=true
fi
if [ -z "${DEVICE}" ]; then
  DEVICE=enp0s25
  DEFAULT=true
fi

if [ "${DEFAULT}" = "true" ]; then
  echo "default applied where not specified"
fi
echo "DEVICE ${DEVICE}"
echo "NETWORK ${NETWORK}"
set -x
(sudo ip route del default via 192.168.${NETWORK}.1 dev ${DEVICE})
