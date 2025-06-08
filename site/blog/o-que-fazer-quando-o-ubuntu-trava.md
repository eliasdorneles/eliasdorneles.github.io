Title: O que fazer quando o Ubuntu trava
Date: 2012-06-30 21:11
Author: Elias Dorneles

Um amigo meu costumava dizer que tudo no Linux é com malabarismos no
teclado, porque certa vez ele conseguiu rebootar um sistema que estava
travado, apertando várias teclas aleatórias ao mesmo tempo
("Alt+Shift+Ctrl+Del+K+Enter", narrava). Tempos depois, ele acabou
adotando o [Linux Ubuntu](http://www.ubuntu.com) no desktop, e embora
ainda tenha problemas de vez em quando, tenho a impressão que ele já se
adaptou bem... Este post é uma homenagem a ele, uma versão em Português
duma [resposta no AskUbuntu à pergunta do que fazer quando o Ubuntu
trava](http://askubuntu.com/questions/4408/what-should-i-do-when-ubuntu-freezes "AskUbuntu - What should I do when Ubuntu freezes")!
:)

Quando um programa pára de funcionar:
-------------------------------------

Quando a janela dum programa pára de responder, você geralmente consegue
parar o programa no botão Fechar (aquele com o X), no canto superior
direito (ou esquerdo, nas versões mais novas do Unity). Geralmente isso
vai resultar numa mensagem avisando que o programa não está respondendo,
e lhe mostrar a opção para matar o programa ou continuar esperando até
ele voltar a responder.

Às vezes isso não funciona como esperado. Se você não consegue fechar
uma janela do jeito normal, você pode abrir um terminal (ou apertar
<kbd>Alt</kbd> + <kbd>F2</kbd>) e executar o comando `xkill`. Feito
isso, o cursor do mouse se transformará em um X, e você pode clicar na
janela com problema para matar o processo, ou clicar com o direito em
qualquer lugar para voltar o mouse ao normal.

Quando comandos rodando num terminal param de responder, geralmente eles
podem ser parados com as combinações <kbd>Ctrl</kbd> + <kbd>C</kbd> ou
<kbd>Ctrl</kbd> + <kbd>/</kbd>. Se nenhum funcionar, você pode abrir
outro terminal (ou tentar recuperar o controle do mesmo com
<kbd>Ctrl</kbd> + <kbd>Z</kbd>), e tentar descobrir o número do processo
para matar "na mão", usando `ps ax | grep COMANDO` onde COMANDO é o nome
do programa que não está respondendo. Isso deve resultar numa saída
parecida com essa:  

    $ ps ax | grep firefox
    2110 ?        Sl    30:32 /usr/lib/firefox/firefox
    2192 ?        Sl    21:19 /usr/lib/firefox/plugin-container /usr/lib/flashplugin-installer/libflashplayer.so -greomni /usr/lib/firefox/omni.ja
    2110 true plugin 4584 pts/0    S+     0:00 grep --color=auto firefox

O primeiro campo de cada linha é o número do processo (PID, de *Process
ID*) dos programas que o `grep` encontrou na busca (você pode ignorar o
último, que representa o próprio `grep`). Para matar o processo, use o
comando: `kill -9 PID_DO_PROCESSO`, usando o número correspondente ao
programa problemático no lugar de *PID\_DO\_PROCESSO*. Você pode ter que
fuçar um pouco mais pra descobrir qual o processo certo da lista,
refinando a busca do `grep` ou então usar o programa `top` no lugar.

Se você estiver usando o [GNOME](http://www.gnome.org), você não precisa
ter que lidar com essas elocubrações na linha de comando pra fazer isso,
simplesmente abra o *Monitor do Sistema* (vá em `Sistema` →
`Administração` → `Monitor do Sistema`), vá para a aba *Processos*,
escolha o processo que você precisa matar (talvez o que está usando 90%
da CPU?), clique com o direito nele e escolha a opção
`Finalizar Processo` ou `Matar Processo`:

[![Terminando um processo usando o Monitor do Sistema do
GNOME](https://eljunior.files.wordpress.com/2012/06/matar_processo.png "GNOME - Monitor do Sistema")](https://eljunior.files.wordpress.com/2012/06/matar_processo.png)

Quando o mouse pára de funcionar:
---------------------------------

Se o teclado ainda funciona, você pode tentar reiniciar o ambiente
gráfico com a combinação <kbd>Alt</kbd> + <kbd>SysReq (Print
Screen)</kbd> + <kbd>K</kbd>. Isso vai fechar todos os programas rodando
no ambiente gráfico e voltar você à tela de login. Opcionalmente, você
pode tentar abrir o `gnome-terminal` com <kbd>Alt</kbd> + <kbd>F2</kbd>
e tentar descobrir o que está acontecendo (quem sabe matar o programa
que avacalhou o mouse?).

Quando tudo, teclas e mouse, param de funcionar:
------------------------------------------------

Tente fazer um reboot seguro usando as [Mágicas do
SysReq](http://jvflima.wordpress.com/2007/01/09/magicas-do-sysreq/ "Mágicas do SysReq").
Isso vai envolver um certo malabarismo tecladístico que faz jus aos
comentários do meu amigo: enquanto mantém pressionadas as teclas
<kbd>Alt</kbd> e <kbd>SysReq (Print Screen)</kbd>, digite a sequência
<kbd>R</kbd> <kbd>E</kbd> <kbd>I</kbd> <kbd>S</kbd> <kbd>U</kbd>
<kbd>B</kbd>. Esses comandos são reconhecidos pelo kernel Linux, que
executam as operações:

- un**R**aw:      recupera o controle do teclado,
- t**E**rminate:  envia o sinal SIGTERM a todos os processos, permitindo que terminem graciosamente,
- k**I**ll:      envia o sinal SIGKILL para todos os processos, forçando-os a terminar imediatamente,
- **S**ync:     sincroniza dados do sistema de arquivos com o disco,
- **U**nmount:  remonta todos os arquivos em modo somente leitura,
- re**B**oot:    reinicia o sistema

> **Nota:** Na época que aprendi essa sequência de comandos, lembro que me ajudou a decorar como *BUSIER* ao contrário...

Se isso não funcionar, então está na hora de reiniciar o computador no dedão!
