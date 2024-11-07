# projeto1_SO
Projeto realizado no âmbito da cadeira de Sistemas Operativos.

### Objetivos:
Desenvolver um script que permita criar e atualizar uma cópia de segurança de uma diretoria de trabalho em outra diretoria, que pode corresponder a um outro dispositivo (pen usb, disco externo, etc), denominada de backup.

### Conteudo:

#### _flags_
- -c:  lista todos os commandos que seriam executados sem os executar
- -b filename: usa um ficheiro passado como argumento como uma lista de caminhos relativos ou absolutos para ficheiros a ignorar pelo script
- -r regex: faz com que o programa apenas copie e atualize ficheiros cujo nome verifique o padrão passado como argumento

#### _backup_files.sh_
Uso: backup_files.sh_ [-c] workdir backupdir

Este script considera que a diretoria de trabalho (workdir) apenas tem ficheiros não tendo qualquer sub-diretoria.
Atualiza apenas os ficheiros com data de modificação posterior à do ficheiro correspondente no backup (backupdir).

#### _backup.sh_ 
Uso: backup.sh [-c] [-b fname] [-r regex] workdir backupdir

Semelhante ao anterior, considera agora que a diretoria de trabalho pode ter ficheiros e subdiretorias.
Utiliza recursão para fazer a cópia de eventuais subdiretorias. Já possui todas as flags implementadas.

#### _backup_files.sh_
Uso: backup_files.sh [-c] [-b fname] [-r regex] workdir backupdir

Em termos de funcionalidade é igual ao anterior, mas agora para
cada diretoria, é escrito na consola um sumário com a indicação do número de erros,
warnings, ficheiros atualizados, ficheiros copiados e ficheiros apagados, e tamanho dos mesmos.

#### _backup_check.sh_
Uso: backup_check.sh workdir backupdir
Este script apenas permite verificar o backup feito com os outro scripts.
