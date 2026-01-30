Title: Sobre construir excelente experiência de usuário - livro EffectiveUI
Date: 2012-11-25 18:48
Author: Elias Dorneles
Status: published

> Este é o primeiro post na idéia de escrever sobre os livros que leio,
> na tentativa de fixar melhor o que tô aprendendo. Rezemos pra que não
> seja o último! :)

O livro é [Effective UI: The Art of Building Great User Experience in
Software,](https://www.amazon.com/Effective-UI-Building-Experience-Software/dp/059615478X "Effective UI na Amazon")
os autores são os fundadores e os empregados da empresa
[EffectiveUI](http://www.effectiveui.com/), no site deles tem uma
[página do
livro](http://www.effectiveui.com/book-resources/ "Effective UI - book resources").
Pelo que entendi, a empresa trabalha principalmente com consultoria de
UX, e o livro é baseado principalmente na experiência deles. Nunca tinha
ouvido falar da empresa antes, mas se a
[O'Reilly](http://oreilly.com/ "oreilly.com") pediu pra eles escreverem
o livro, imagino que eles devem saber do que estão falando. :)  

<center>

[![Effective UI book cover](https://learning.oreilly.com/library/cover/9781449380465/250w/ "EffectiveUI - livro")](http://shop.oreilly.com/product/9780596154790.do)
</center>

Ele trata do assunto: *"como fazer um projeto de software de qualidade,
considerando a experiência do usuário -- UX (User eXperience)"*. Quando
me recomendaram esse livro, pensei que trataria de alguns princípios
básicos de interface e que talvez tivesse algumas receitas de bolo para
serem aplicadas no desenho de interfaces na prática. Todavia, um projeto
de experiência do usuário [1] envolve muito mais do que questões de
leiaute, tamanhos e tipografia. De acordo com os autores, para fazer
softwares que estimulem o envolvimento do usuário e ajudem-no a fazer
suas tarefas, é necessário construir um certo clima desde o começo do
projeto, que possibilite a equipe ser eficiente, e manter esse clima
durante o projeto até o fim. Por isso, acho que posso dizer que esse
livro também é sobre como escapar das armadilhas que causam a maioria
dos softwares serem muito ruins de usar, e que fazem projetos
fracassarem antes de você ouvir falar deles.

> [1]: minha tradução para [User experience design](https://en.wikipedia.org/wiki/User_experience_design), não sei se existe termo melhor.

Boa parte dos conselhos do livro são diretamente aplicáveis para pessoas
envolvidas com liderança de projetos, mas o conteúdo interessa qualquer
pessoa que esteja envolvido em algum esforço pra produzir software de
qualidade.

O engraçado é que, se eu soubesse de antemão exatamente do que o livro
tratava, acho que eu não teria me interessado. Mas como me recomendaram
como sendo um livro muito bom, resolvi ler e ver o que conseguiria
aprender, e no fim das contas valeu muito a pena! O livro é bem
abrangente, e fala de muita coisa que como desenvolvedor, é muito útil
eu me dar conta. Ainda assim, tenho a impressão que algumas lições ainda
vão demorar pra amadurecer na minha cabeça.

Alguns pontos importantes do livro:

-    Melhorias na experiência do usuário (UX) de um produto podem render
    facilmente retorno sobre investimento, pois criam valor ajudando os
    usuários a atingir seus objetivos.
-   A responsabilidade pela experiência do usuário é de todo mundo, e
    não funciona sendo delegada a alguns departamentos isolados -- basta
    lembrar de como é "divertido" ligar para o call-center da sua
    prestadora de telefonia...
-   Na hora de vender a idéia de melhorar a UX para as partes
    interessadas
    (*[stakeholders](https://pt.wikipedia.org/wiki/Stakeholder "Stakeholder na Wikipedia")*),
    exponha-as ao feedback dos usuários. Os autores inclusive contam uma
    história de como os *stakeholders* de um projeto finalmente
    decidiram priorizar a melhoria da usabilidade de um produto, depois
    de assistirem o vídeo de um usuário muito irritado com o software a
    ponto de esmurrar o teclado.
-   Você nunca tem todas as respostas antes do produto ser
    desenvolvido. Especificações e requerimentos funcionais feitos antes
    de começar o desenvolvimento são instantaneamente deficientes por
    terem sido feitos da perspectiva menos informada. Em vez de perder
    tempo definindo especificações, descubra os objetivos e as
    prioridades dos usuários e do negócio. Atingir os objetivos do
    negócio por meio de habilitar os usuários a atingir seus objetivos
    == sucesso.
-   Intolerância a incertezas é intolerável. Durante a maior parte do
    projeto, sempre haverá incerteza e desconhecidos, aprender a lidar
    com isso é fundamental. Planejamento detalhado demais está fadado ao
    fracasso porque muito do desconhecido ainda não foi descoberto.
    Evite os problemas do [Big Design Up
    Front](https://en.wikipedia.org/wiki/Big_Design_Up_Front) e comece o
    desenvolvimento o mais rápido possível. Quanto mais adiante no
    projeto você estiver, mais sábio você será. Por isso, descubra os
    objetivos cedo e postergue as decisões sobre os detalhes.
-   A coisa mais importante que pode ser feita para o sucesso de um
    projeto é montar a melhor equipe. A equipe deve reconhecer a
    importância das necessidades dos usuários para o produto. Sem
    empatia com os usuários, os desenvolvedores podem acabar
    sacrificando UX pelo que é mais fácil de fazer (ou por um “desejo de
    elegância” para o modelo), os designers podem focar demais em deixar
    bonito em vez de funcional, e outros colaboradores podem dar
    importância demais às suas suposições sobre como o produto deve ser
    e deixar de lado a pesquisa de usuário: tudo isso sacrifica a
    qualidade do produto e diminui as chances dum bom retorno sobre o
    investimento.

Além da parte inicial que apresenta alguns conceitos de UX, explica sua
importância e por que você deveria se importar, o livro tem um capítulo
muito interessante sobre como capturar a perspectiva do negócio. Nele
são descritos alguns exercícios úteis para ajudar a descobrir as
expectativas das partes interessadas, encontrar as reais necessidades
por trás das idéias formuladas (por exemplo, alguém pode dizer que deve
haver um mecanismo para os usuários trocarem emails, em vez de expor a
necessidade de  compartilhamento de recursos e facilidades de
colaboração), estabelecer o público-alvo do produto e as características
de alguns usuários desse público, e ainda, priorizar quais são as partes
importantes disso tudo. Basicamente, uma sucessão de negociações e de
aplicações do [princípio de
Pareto](https://pt.wikipedia.org/wiki/Princ%C3%ADpio_de_Pareto "Princípio de Pareto")
para descobrir o que é realmente necessário.

Mas o trecho que mais me chamou a atenção foi o capítulo intitulado
Arquitetura Inicial do Produto (*Initial Product Architecture*), que
discorre sobre as decisões iniciais do desenvolvimento, sobre coisas que
serão difíceis de mudar depois. A hora em que são respondida perguntas
tipo: "Que tamanho é esse troço que vamos fazer?" "Que outros produtos
teremos que integrar?" "Quais linguagens/plataformas vamos utilizar?" 
"Como os componentes serão conectados?” “Como as pessoas vão usar as
coisas que vamos criar?” “Que ‘cara’ o produto vai ter?”, e várias
outras. Segundo os autores, são dois tipos de “arquitetos” que trabalham
nessa parte: os "arquitetos de UX" e os "arquitetos técnicos".

Os arquitetos de UX usariam seus conhecimentos (que envolvem usualmente
usabilidade, design gráfico, práticas de engenharia de software, etc,
até psicologia) para produzir um refinamento das soluções a serem
desenvolvidas através de descrições de cenários contextuais, guias de
estilos, mapeamento de fluxos da interface, elaboração de nomenclatura,
e outras coisas mais. O livro detalha algumas técnicas usadas, e eu
curti em especial a parada sobre o uso de cenários ([exemplos
aqui](http://uxsuccess.com/2009/12/01/agile-personas-and-context-scenario/ "Agile Personas and Context Scenario")
- em inglês), porque esses tempos comecei a fazer algo parecido num
projeto sem saber, e me pareceu que funcionava legal. A sacada desses
cenários é que você descreve os passos que o usuário precisa para fazer
uma tarefa, mas não precisa especificar cada detalhezinho que você não
precisa definir. Dessa forma, os cenários representam as características
tradicionais de um *framework*: deixam fixo e estável o que já se sabe,
flexível e maleável o que ainda precisa ser descoberto.

Ainda nesse mesmo estágio de arquitetura inicial, os arquitetos técnicos
resolveriam os aspectos técnicos chave do produto que devem ser
definidos de antemão, tendo em vista as necessidades e restrições
existentes. As tarefas geralmente envolvem coisas como descobrir quais
recursos existentes serão aproveitados, quais linguagens/plataformas
devem ser usadas, que elementos de infraestrutura serão necessários, e
por último mas não menos importante, começar a identificar a lógica de
negócio (que usualmente está espalhada em outros softwares, planilhas
Excel e às vezes apenas na cabeça de algumas pessoas).

Por fim, os últimos dois capítulos tratam sobre o restante do projeto
(onde é gasto a maior parte do tempo), ressaltando a importância de
feedback e de comunicação durante todas as etapas do projeto. O primeiro
deles discorre especificamente sobre a importância do processo de
desenvolvimento ser
[iterativo](https://pt.wikipedia.org/wiki/Desenvolvimento_iterativo_e_incremental "Desenvolvimento iterativo e incremental - Wikipedia"),
para agilizar a obtenção de *feedback* e a reavaliação das decisões,
restrições e objetivos levando em conta o *feedback*obtido. Esse
capítulo dá algumas idéias interessantes sobre minimizar as desvantagens
de um processo de desenvolvimento problemático que você pode estar sendo
forçado a trabalhar (como um
[cascata](https://pt.wikipedia.org/wiki/Modelo_em_cascata) ou um
[BDUF](https://en.wikipedia.org/wiki/Big_Design_Up_Front "Big Design Up Front")):

-    permitir mais liberdade nas etapas posteriores de desenvolvimento;
    às vezes isso pode ser feito simplesmente renomeando os documentos
    “requisitos” e “especificações” produzidos para “diretrizes” e
    “recomendações”. :)
-   envolver profissionais de outras disciplinas nas diferentes etapas:
    colocar alguns profissionais de UX e desenvolvedores também para
    trabalhar na definição dos requisitos de negócio, envolver também
    pelo menos um especialista de UX e de negócio na etapa de
    desenvolvimento.
-   apressar as primeiras etapas para chegar logo na etapa de
    desenvolvimento, que será melhor de responder as perguntas. Qualquer
    especificação feita antes será cheia de erros e omissões e muitas
    vezes são criadas apenas por necessidades burocráticas, então é
    melhor não gastar muito tempo nisso e ir logo para a etapa em que as
    respostas serão realmente obtidas.

E o último é sobre as ações relacionadas aos *releases*, que devem ter
como objetivo obter feedback (versão *alpha* para feedback de usuários
internos, versão *beta* para feedback de uma amostra de usuários mais
perto do real), e também das tarefas necessárias após o *release*:
marquetar o produto (muito necessário, mesmo que seja para uso interno
da organização), montar a documentação para os usuários (de preferência
embutida no próprio produto, disponível no contexto), e recapitular as
lições aprendidas. É importante verificar se os objetivos do negócio
originais estão sendo alcançados, e os objetivos do usuário também: o
resultado pode virar material para o próximo projeto. Pode ser útil
embutir no produto mecanismos para rastrear as ações dos usuários, para
verificar quais áreas requeiram atenção.

Enfim, talvez esse texto tenha ficado comprido demais, mas pode também
ser um bom sinal: o livro é bom e até que aprendi bastante coisa.
Recomendo!

<small>Valeu, Filipi
([NEXTT](http://www.nextt.com.br/ "www.nextt.com.br")), pela
recomendação do livro. :)</small>
