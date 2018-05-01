Title: Desenho de Interface do Usuário - para programadores
Date: 2013-03-18 22:57
Author: Elias Dorneles
Slug: Desenho-de-Interface-do-Usuário---para-programadores

[Joel Spolsky](http://www.joelonsoftware.com/) é um cara batuta e muito
inteligente. Ele é uma das figuras por trás do
[Trello](https://www.trello.com/) e do
[StackOverflow](http://stackoverflow.com/) (e seus [sites
irmãos](http://stackexchange.com/)), dois produtos show de bola que têm
sido parte da minha vida diária ultimamente. Ele também é bastante
conhecido pelos excelentes textos que escreveu no blog sobre vários
aspectos de desenvolvimento de software, cobrindo assuntos desde
gerenciamento de projetos, arquitetura e design de software, usabilidade
e também contratação de funcionários. Resumindo: HERÓI! Se você lê
inglês, ou quer aprender (e se você é programador, isso é altamente
recomendado), dê uma olhada por lá! Aqui, vou deixar fácil:
[http://www.JoelOnSoftware.com](http://www.joelonsoftware.com/)

Num fim de semana desses, gastei duas horinhas lendo [a versão online do
mini-livro dele voltado para programadores que trata desenho de
interfaces de
usuário](http://www.joelonsoftware.com/uibook/fog0000000249.html) (tem
[outra versão à venda na Amazon que parece ter mais
conteúdo](http://www.amazon.com/User-Interface-Design-Programmers-Spolsky/dp/1893115941)).
Tempo muito bem gasto, diga-se de passagem, porque o conteúdo é muito
bom! O Joel escreve bem pra caramba, a leitura é muito engajante e as
histórias que ele conta são bem divertidas.

**UPDATE:** Recentemente, descobri que tem [uma tradução dos posts do Joel Spolsky que fizeram o livro aqui](http://brazil.joelonsoftware.com/ "Tradução dos posts do Joel"): [http://brazil.joelonsoftware.com](http://brazil.joelonsoftware.com/).

Ele comenta sobre o desgosto que alguns programadores têm de fazer
interfaces, provavelmente baseado no medo injustificado de ter que fazer
[design gráfico](http://pt.wikipedia.org/wiki/Design_gr%C3%A1fico) (não,
não é a mesma coisa que *desenho de interface -- UI design*).
Programadores tendem a pensar sobre si mesmos como pessoas racionais,
com bom raciocínio mas fraco em arte. Todavia, Joel explica, desenho de
interface não é nenhuma arte misteriosa, e na verdade existem uma série
de regras e princípios que podem ser aplicados para melhorar a interface
dos programas para o usuário.

O caso é que a interface é importante porque afeta as emoções das
pessoas. Quando um usuário não consegue fazer o que ele queria com o
software, fica frustrado. Infeliz, mesmo! Mesmo que sejam algumas
pequenas frustraçõezinhas, elas tendem a se somar, principalmente num
software que é usado frequentemente. E o resultado é um grupo de
usuários bem infelizes, no fim do dia. E eles vão botar a culpa no seu
software!

Todavia, quando o usuário consegue fazer o que queria, o programa
funciona do jeito que ele esperava, o resultado é um usuário bem
animado. *Funcionou! Ripei um DVD! Que massa esse programa! \o/*

Por isso, a primeira coisa importante a se ter em mente é:

### Uma interface é bem-feita quando o programa se comporta exatamente como o usuário esperava.

Todas as regras e princípios restantes são corolários a esta.

Quando um usuário senta pra usar um programa, ele tem uma série de
expectativas sobre como ele acha que o programa vai funcionar. Se ele já
usou outros programas parecidos antes, vai achar que esse vai funcionar
mais ou menos como aquele outro. Essas expectativas que devemos tentar
descobrir, na hora de fazer uma interface pra o usuário. E você descobre
isso de um jeito muito científico, e muito simples: **perguntando aos
usuários!** Você não precisa *fazer* o que eles querem que você faça,
mas você deve pelo menos *ouvir* o que eles têm a dizer.

Em vez de ficar argumentando e discutindo qual o melhor jeito de tratar
determinado problema, simplesmente pergunte a alguns usuários o que eles
esperariam como solução. É claro que alguns podem não saber, não se
interessar ou simplesmente nunca ter pensado muito a respeito, mas se
você perguntar pra gente suficiente eventualmente vai começar a enxergar
uma espécie de consenso. E aí você já pode fazer um teste de usabilidade
usando um protótipo da interface e pedindo pra alguns usuários tentar
completar algumas tarefas, enquanto você observa.

Nessa hora você pode descobrir algumas coisas interessantes, tipo como
certos usuários tentam clicar em coisas que não são clicáveis, ou
procuram por uma certa opção num lugar diferente no menu. Talvez você
perceba que precisará melhorar o suporte a copiar e colar em alguns
campos, ou oferecer uma opção para desfazer certas ações, talvez
reescrever os rótulos de alguns botões, e outras coisas do tipo. O legal
é que você nem precisa fazer o teste com muitos usuários: mais de cinco
ou seis pessoas e os resultados já começarão a se repetir! Resumindo,
não requer nenhum investimento pesado em pesquisa.

Enfim, fazendo as coisas dessa maneira você consegue ter uma idéia
melhor do que é que os usuários esperam. Você pode descobrir que
melhorará a vida duma grande porcentagem dos usuários se construir sua
aplicação a respeito de tarefas dos usuários, em vez de uma série de
recursos genéricos não muito claros. Está no caminho para construir uma
interface que atenda essas expectativas.

Uma coisa que reforça esse assunto, é a questão da [consistência
externa](http://web.cs.wpi.edu/~matt/courses/cs563/talks/smartin/int_design.html),
isto é, a consistência com as outras ferramentas que o usuário está
acostumado (este assunto é também tratado [no livro sobre experiência do
usuário que comentei há uns tempos
atrás](http://eljunior.wordpress.com/2012/11/25/livro-effectiveui-minhas-notas/)).
Quando as primeiras aplicações começaram a aparecer, todo mundo precisou
imaginar os próprios atalhos, menus e botões para determinadas coisas.
Ainda existe muito software daquela época que é assim até hoje, em que
mesmo o jeito de fechar o programa é bem diferente (*hello, Emacs... and
vim :*).

Hoje em dia, as aplicações Web tentam se aproximar bastante à
experiência oferecida pelas aplicações Desktop, porque corresponde
melhor às expectativas dos usuários. Estou escrevendo este texto no
Google Docs e sou grato ao Google por ter mantido no Docs a interface
familiar das outras suítes de Office -- menus
Arquivo/Editar/Formatar/etc, a barra de ferramentas, a maioria dos
atalhos para formatação também simplesmente funcionam. Imagina se eles
resolvessem: *“ei, nossa aplicação é Web, não tem nada a ver com o
Office tradicional, vamos então prover uma experiência totalmente nova!
Arquivos são coisas do passado, nós não temos arquivos, temos documentos
na nuvem, então esse item File no menu não faz sentido!”* Ainda bem que
não rolou nada disso, certo? (Certo, Google?)

Por isso, ao fazer a interface do seu programa, faça o favor de seguir
as convenções que os outros estão usando -- mesmo que elas tenham sido
estabelecidas por certas gigantes multinacionais pelas quais você não
tem muito carinho. Para construir interfaces usáveis deixe a ideologia
de lado, os usuários agradecem. Caso contrário, você corre o risco de
ser [aquele hotel que resolveu fazer tudo diferente e deixou impossível
pra um recém-chegado descobrir como acender as luzes do quarto ou abrir
a torneira](http://sivers.org/quirks).

A segunda grande regra de desenho de interface do Joel é:

### Cada vez que você apresenta uma opção, você está pedindo ao usuário para tomar uma decisão.

O que não é necessariamente uma coisa ruim, é claro. Todo mundo gosta de
poder escolher certas coisas, é por isso que Subway, Spoletto e outros
restaurantes do tipo fazem sucesso. Todavia, ninguém gosta de escolher
coisas que *simplesmente não interessam*.

  [![Lembra desse cara chato?](https://eljunior.files.wordpress.com/2013/03/clippy-letter20110724-22047-qcxdai.png)](https://eljunior.files.wordpress.com/2013/03/clippy-letter20110724-22047-qcxdai.png)
  Lembra desse cara chato?

E a verdade é que a maioria dos usuários não se importam com tanta coisa
quanto você pode achar. Joel dá um exemplo do que não fazer, citando o
caso da ajuda do Windows, que em vez de mostrar a ajuda, abria um wizard
perguntando como você queria configurar o índice da ajuda... É igual
como quando você está tentando trabalhar em alguma coisa e alguém fica
interrompendo, exigindo sua atenção para um assunto inútil.

Outro exemplo de problema do tipo foi a possibilidade de configurar a
posição das barras de ferramentas... Você pode configurar tanto, que
pode inclusive extrair a barra pra uma janela separada (e depois lutar
bastante pra colocá-la de volta no lugar original). Aí você tem uma
coisa que ninguém quer, mas que acaba atrapalhando para todo mundo.

Resumindo: *pense muito bem antes de forçar o usuário decidir sobre uma
coisa*. Em geral, você deve tentar minimizar a quantidade de decisões,
deixando apenas o que realmente importa.

## Como criar interfaces para pessoas que têm mais o que fazer na vida

Quando você desenha interfaces para o usuário, diz Joel, é uma boa idéia
manter dois princípios em mente:

1.  **Usuários não lêem o manual**
2.  **Na verdade, usuários não lêem nada**

Usuários não lêem o manual por diversos motivos. Às vezes, eles nem
*têm* o manual, mas não iam querer ler mesmo se tivessem. Em geral, seus
usuários estão tentando *fazer* alguma coisa. Para eles, ler o manual é
interromper a tarefa que estão fazendo, é mais perda de tempo (e tendo
em vista como tantos manuais são escritos mal, frequentemente eles estão
corretos em assumir isso).

E de fato, usuários não lêem nada! Isso pode soar meio bizarro, mas a
verdade é que existem muitas pessoas que simplesmente não lêem as
palavras que estão escritas na tela. Isso é muito azarado para o
programador, que geralmente gosta de imaginar tendo uma espécie de
diálogo com o usuário. Mas se você já parou para observar as outras
pessoas usando o computador, provavelmente já percebeu que algumas nunca
lêem o que aparece num diálogo e automaticamente clicam em *Ok* ou
*Cancelar* -- dependendo do nível de confiança de cada uma.

Eu conheço de perto um programador que se comporta exatamente dessa
forma. O bicho simplesmente não lê as mensagens que aparecem na tela,
mesmo quando vai usar um programa que não está acostumado, é incrível!
Incidentalmente, ele vive reclamando que os usuários dos programas dele
não lêem as mensagens na tela...

Mas é assim mesmo. Os usuários avançados usualmente pulam as instruções.
Iniciantes não gostam mesmo de ler muito. E os poucos usuários que realmente
tentam ler as instruções, muitas vezes acabam ficando ainda mais confusos
depois de lê-las! Por isso, os textos que você põe na tela devem ser polidos
para minimização. Substitua explicações por ações auto-explicativas. Dá mais
trabalho fazer assim porque você precisa pensar mais para conseguir reduzir os
textos, mas vale a pena. **Menos é realmente mais.**

Ok. Joel fala de várias outras coisas também, mas este texto está ficando
grande demais, e você é um herói legendário tendo lido até aqui de qualquer
forma, então, prometo que já-já vou terminar.

Outra coisa que usuários também não são muito bons em fazer é controlar o
mouse. Pois é, eles não controlam o mouse muito bem. Meus pais mesmo tiveram
uma certa dificuldade de aprender o duplo clique. Certas tarefas são
particularmente complicadas de fazer com o mouse. E às vezes, mesmo se o
usuário sabe usar o mouse, ele não funciona muito bem. Eu mesmo cansei de
xingar aplicações com barras de rolagem muito chatas, em que algumas tarefas
simples viram um exercício de autocontrole pra não socar o monitor. E até hoje
ainda tenho alguns medinhos sobre clicar e arrastar...

Outra coisa a lembrar: Usuários não conseguem lembrar muita coisa.
Praticamente, nadica! E é por isso que menus são melhores interfaces que linhas
de comando crípticas. Por isso que escolher um arquivo de imagem selecionando
uma miniatura da imagem é melhor do que procurar o nome do arquivo numa lista.
E por isso que, mesmo quem jura que a linha de comando é uma interface melhor,
não larga do autocompletar. :)

E ei, eu sou um que vivo na linha de comando, uso na grande maioria das minhas
tarefas no PC. Mas não tem como negar que o Windows Explorer apresentando as
pastas em árvore é uma metáfora *beeem* melhor para o sistema de arquivos. Eu
na linha de comando é só eu na minha zona de conforto. Eu devia tentar usar
mais a interface gráfica, mas...

Ok, agora sim, estou finalizando! O que segue é provavelmente o ponto mais
importante de todo esse texto.

Alguém lendo este texto, pode achar que um princípio geral a ser seguido é:
*“pense que seus usuários são muito burros”*, e talvez achar que essa seja uma
atitude arrogante. Não muito, eu diria... *Uma arrogância muito pior é achar
que o seu software é tão bom e bem-feito que as outras pessoas simplesmente
devem se virar pra aprender a usá-lo*.

[![UI-usuarios-final](https://eljunior.files.wordpress.com/2013/03/ui-usuarios-final.png)](https://eljunior.files.wordpress.com/2013/03/ui-usuarios-final.png)

Pense comigo. A grande maioria das pessoas sabe operar uma televisão.
Uma boa porção dessas pessoas deve ser capaz de usar o PC, navegar na
Internet e olhar email, criar tabela no Excel. Uma porção pequena dessas
pessoas deve saber usar Linux, talvez usar um pouco a linha de comando,
e usar o último *tablet* da moda. Pouquíssimas dessas pessoas saberão
programar. E das que sabem, muito poucas saberão programar em C++. (*Cá
entre nós, quase nenhuma mesmo, mas vai ter muitas que acham que sabem!
:D*)

O que podemos concluir disso é que *quando você melhora a interface do
seu programa, mesmo que em pequena quantidade, você aumenta
dramaticamente o número de pessoas que pode usá-lo* com facilidade.
Melhore a interface para o *noob* que mal e mal sabe usar a TV, e a
interface vai melhorar pra todo mundo -- inclusive para os hackers
barbudinhos! Tipo, melhore a interface em 10%, e ganhe 50% mais
usuários. Por isso também, que fazer pequenas melhoras numa aplicação
ruim que é usada largamente, pode valer muito mais a pena do que criar
uma aplicação nova toda perfeitinha, que talvez não tenha tanto público.

Então, não é que os seus usuários sejam tolos, mas sim que se você
seguir tentando fazer seu sistema à prova de tolos, você chegará num
programa fácil de usar pra todo mundo. De fato, se fazer de tolo é uma
boa maneira de avaliar a usabilidade de um programa ou tela. Não ler o
que tá escrito na tela, sair clicando onde acha que deve ser, usar o
mouse com um dedo só. Se a interface não aguenta você sendo imaturo e
impaciente, provavelmente ela pode ser melhorada um bocado.

Finalmente, o último conselho é: **faça seu programa girar em torno de
atividades do usuário**. Se você vai fazer um produto, não saia
simplesmente criando os recursos que acha que será necessário. Imagine
alguns usuários (Pedro, pai de família, usa o PC para ver vídeos no
YouTube e trocar emails com os amigos. Luana, filha adolescente de
Pedro, passa as tardes no Facebook e baixa MP3 via BitTorrent). Isso
deve ajudar a despertar empatia por eles. Então você pode imaginar
algumas *coisas* que esses usuários queiram *fazer* com seu programa. E
o passo seguinte é ter certeza de deixar bem óbvio como essas coisas
podem ser feitas, na interface do seu programa.

Dessa maneira você evita uma aplicação que os usuários tenham que ler o
manual (que ele não tem, lembra?) pra ver o que pode fazer com ela. De
cara, ele já pode descobrir como fazer o que precisa. *Ripar um CD*.
Enviar um cartão de Feliz Aniversário. *Criar álbum de fotos*. Imprimir
o artigo inteiro. *Achar uma imagem para ilustrar o texto*. Revisar os
últimos comentários postados.

Uma interface desenhada em torno de atividades sempre vai detonar uma
desenhada em cima de quantidade de recursos, tranquilamente e de mãos
atadas!

Era isso, chega por hoje! :)
