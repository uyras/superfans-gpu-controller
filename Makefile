all: superfans-gpu-controller superfans-gpu-controller.service
.PHONY: all superfans-gpu-controller-daemon install uninstall clean

service_dir=/etc/systemd/system
conf_dir=/etc

src_python_dir=python

superfans-gpu-controller: $(src_python_dir)/superfans_gpu_controller.py $(src_python_dir)/setup.py
	pip3 install $(src_python_dir)/.

superfans-gpu-controller.service: $(src_python_dir)/superfans_gpu_controller.py superfans-gpu-controller
# awk is needed to replace the absolute path of mydaemon executable in the .service file
	sed "s|__path__|$(shell PATH=/usr/local/bin:$$PATH which superfans-gpu-controller)|g" etc/systemd/system/superfans-gpu-controller.service.template > etc/systemd/system/superfans-gpu-controller.service

install: $(service_dir) $(conf_dir) superfans-gpu-controller.service
	cp etc/superfans-gpu-controller.json $(conf_dir)
	cp etc/systemd/system/superfans-gpu-controller.service $(service_dir)
	-systemctl enable superfans-gpu-controller.service
	-systemctl enable superfans-gpu-controller
	-systemctl start superfans-gpu-controller

uninstall:
	-systemctl stop superfans-gpu-controller
	-systemctl disable superfans-gpu-controller
	-rm -r $(service_dir)/superfans-gpu-controller.service
	-rm -r $(conf_dir)/superfans-gpu-controller.json
	-systemctl daemon-reload
	-systemctl reset-failed
	pip3 uninstall -y superfans-gpu-controller
	
clean:
	-rm etc/systemd/system/superfans-gpu-controller.service
