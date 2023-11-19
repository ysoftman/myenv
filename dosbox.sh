if which dosbox; then
    dosbox --args -conf ${myenv_path}/dosbox.conf
else
    open -a DOSBox --args -conf ${myenv_path}/dosbox.conf
fi

