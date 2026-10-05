Coloque aqui os arquivos de som (formato .mp3 recomendado):

- door_open.mp3       -> ao abrir uma geladeira
- door_close.mp3      -> ao sair da tela da geladeira
- paper.mp3           -> ao criar um post-it
- magnet.mp3          -> ao "fixar" um post-it na geladeira
- confirm.mp3         -> ao concluir um lembrete
- notification.mp3    -> ao receber um novo comentário

Depois de adicionar os arquivos, abra o pubspec.yaml e descomente o
bloco `assets:` (está comentado no final do arquivo, com o caminho de
cada som). Sem isso, o Flutter não vai empacotar os arquivos, e os
sons continuam simplesmente não tocando (sem quebrar o app).

Não é obrigatório ter sons reais para o projeto funcionar ou para os
outros requisitos da atividade — isso é só o efeito sonoro opcional
da Prioridade 12.
