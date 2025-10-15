‎Instrucciones para configurar Docker en Codespace
‎Verifica el almacenamiento disponible
‎En la terminal, ejecuta el siguiente comando para ver las particiones y el almacenamiento disponible:
‎
‎df -h
‎Elige la partición con mayor capacidad de almacenamiento.
‎
‎Crea la carpeta para Docker
‎Ejecuta el siguiente comando para crear la carpeta donde Docker almacenará los datos:
‎
‎sudo mkdir -p /tmp/docker-data
‎Configura Docker
‎Ahora, edita el archivo de configuración de Docker:
‎
‎sudo nano /etc/docker/daemon.json
‎Pega el siguiente contenido:
‎
‎{
‎  "data-root": "/tmp/docker-data"
‎}
‎Reinicia tu Codespace
‎Apaga y enciende nuevamente tu Codespace para aplicar los cambios.
‎
‎Verifica la configuración
‎Para asegurarte de que Docker está configurado correctamente, ejecuta:
‎
‎docker info
‎Crear archivo windows10.yml
‎Crea un archivo llamado windows10.yml con el siguiente contenido:
‎
‎services:
‎  windows:
‎    image: dockurr/windows
‎    container_name: windows
‎    environment:
‎      VERSION: "10"
‎      USERNAME: ${WINDOWS_USERNAME}   # Usa un archivo .env para variables sensibles
‎      PASSWORD: ${WINDOWS_PASSWORD}   # Usa un archivo .env para variables sensibles
‎      RAM_SIZE: "4G"
‎      CPU_CORES: "4"
‎    cap_add:
‎      - NET_ADMIN
‎    ports:
‎      - "8006:8006"
‎      - "3389:3389/tcp"  # Solo exponemos TCP para RDP
‎    volumes:
‎      - /tmp/docker-data:/mnt/disco1   # Asegúrate de que este directorio exista
‎      - windows-data:/mnt/windows-data # Montaje adicional si es necesario
‎    devices:
‎      - "/dev/kvm:/dev/kvm"  # Solo si realmente necesitas acceso a KVM
‎      - "/dev/net/tun:/dev/net/tun"  # Solo si necesitas acceso a interfaces de red virtual
‎    stop_grace_period: 2m
‎    restart: always
‎
‎volumes:
‎  windows-data:  # Define el volumen en caso de que no exista
‎
‎Crear archivo .env
‎Crea un archivo .env en la misma carpeta donde se encuentra windows10.yml para definir las variables de entorno sensibles, como el nombre de usuario y la contraseña:
‎
‎WINDOWS_USERNAME=YourUsername
‎WINDOWS_PASSWORD=YourPassword
‎Este archivo no debe subirse a repositorios públicos por razones de seguridad. Asegúrate de incluirlo en tu .gitignore si estás trabajando con control de versiones.
‎
‎Levantar el contenedor
‎Levanta el contenedor ejecutando el siguiente comando:
‎
‎docker-compose -f windows10.yml up
‎Inicia el contenedor con:
‎
‎docker start windows
‎¡Y listo! Con estos pasos, habrás configurado correctamente Docker y creado el contenedor de Windows 10 en tu Codespace. Si tienes más dudas o necesitas asistencia adicional, no dudes en preguntar.
‎
