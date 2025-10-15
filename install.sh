‎Perfecto 👏
‎Aquí tienes todo el texto + el código completo (en formato limpio y funcional) para configurar Docker dentro de un GitHub Codespace y luego crear un contenedor de Windows 10 usando la imagen dockurr/windows.
‎
‎
‎---
‎
‎🧩 Instrucciones completas para configurar Docker en Codespace
‎
‎1️⃣ Verifica el almacenamiento disponible
‎
‎Abre la terminal en tu Codespace y ejecuta:
‎
‎df -h
‎
‎👉 Busca la partición con mayor espacio disponible. Normalmente /tmp tiene bastante espacio.
‎
‎
‎---
‎
‎2️⃣ Crea la carpeta para Docker
‎
‎sudo mkdir -p /tmp/docker-data
‎
‎
‎---
‎
‎3️⃣ Configura Docker
‎
‎Edita el archivo de configuración del daemon de Docker:
‎
‎sudo nano /etc/docker/daemon.json
‎
‎Pega este contenido:
‎
‎{
‎  "data-root": "/tmp/docker-data"
‎}
‎
‎Guarda con Ctrl + O, luego Enter, y sal con Ctrl + X.
‎
‎
‎---
‎
‎4️⃣ Reinicia el Codespace
‎
‎Para aplicar los cambios, apaga y vuelve a encender el Codespace.
‎O, alternativamente, reinicia Docker manualmente:
‎
‎sudo systemctl restart docker
‎
‎
‎---
‎
‎5️⃣ Verifica la configuración
‎
‎Comprueba que Docker esté usando la nueva ruta:
‎
‎docker info
‎
‎Busca la línea:
‎
‎Docker Root Dir: /tmp/docker-data
‎
‎
‎---
‎
‎🪟 6️⃣ Crear el archivo windows10.yml
‎
‎Crea un archivo llamado windows10.yml:
‎
‎nano windows10.yml
‎
‎Pega este contenido:
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
‎      - "/dev/kvm:/dev/kvm"          # Solo si tu Codespace lo soporta
‎      - "/dev/net/tun:/dev/net/tun"  # Solo si necesitas acceso a red virtual
‎    stop_grace_period: 2m
‎    restart: always
‎
‎volumes:
‎  windows-data:
‎
‎Guarda y cierra el archivo.
‎
‎
‎---
‎
‎🔐 7️⃣ Crear archivo .env
‎
‎Crea el archivo .env en la misma carpeta:
‎
‎nano .env
‎
‎Agrega:
‎
‎WINDOWS_USERNAME=Deepak
‎WINDOWS_PASSWORD=sankhla
‎
‎⚠️ Importante:
‎No subas este archivo a repositorios públicos.
‎Agrega una línea a tu .gitignore:
‎
‎.env
‎
‎
‎---
‎
‎🚀 8️⃣ Levantar el contenedor
‎
‎Ejecuta:
‎
‎docker-compose -f windows10.yml up
‎
‎El sistema descargará la imagen dockurr/windows y creará un contenedor con Windows 10 virtualizado (modo emulado).
‎
‎Luego puedes iniciar el contenedor con:
‎
‎docker start windows
‎
‎
‎---
‎
‎✅ Resultado esperado
‎
‎Docker usará /tmp/docker-data como almacenamiento.
‎
‎Se levantará un contenedor con Windows 10 accesible vía RDP (puerto 3389).
‎
‎Podrás conectarte usando:
‎
‎Host: localhost
‎
‎Puerto: 3389
‎
‎Usuario y contraseña: los definidos en tu .env.
‎
‎
‎
‎
‎---
‎
‎¿Quieres que te prepare un script automático (setup_windows10.sh) que ejecute todos estos pasos de una vez en tu Codespace (listo para copiar y pegar)?
‎
