myvar=$(ps -efw | grep harmony | grep -v grep | awk '{print $2}')
if test -z "$myvar"
then
  echo "empty"
else
  echo "not empty"
  sudo kill $(ps -efw | grep harmony | grep -v grep | awk '{print $2}')
fi
