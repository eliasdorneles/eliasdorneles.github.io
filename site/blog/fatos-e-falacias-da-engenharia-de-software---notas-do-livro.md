Title: Fatos e Falácias da Engenharia de Software - notas do livro
Date: 2012-12-03 13:23
Author: Elias Dorneles
Status: published

[![Book cover](https://codinghorror.typepad.com/.a/6a0120a85dcdae970b012877703e5c970c-pi)](https://www.amazon.com/Facts-Fallacies-Software-Engineering-Robert/dp/0321117425)Acabo
de terminar a leitura de um livro simplesmente excelente, *Facts and
Fallacies of Software Engineering* (Fatos e Falácias da Engenharia de
Software), do programador/pesquisador/escritor [Robert L.
Glass](https://en.wikipedia.org/wiki/Robert_L._Glass). Bob Glass não é
um acadêmico que fica falando abobrinha sobre como deve ser feito
software mas que nunca quer botar a mão na massa. Ele se descreve como
um pesquisador e <span
style="text-decoration: underline;">praticante</span> de engenharia de
software (com 45 anos na área), e ele tem mesmo muita coisa interessante
pra dizer.

O livro -- dedicado aos pesquisadores que acenderam o fogo da ES e aos
praticantes que mantêm-no aceso -- consiste em 55 fatos apresentados num
formato fácil de ler (fato, discussão, controvérsia, fontes &
referências) e mais 10 falácias que ele resolveu adicionar depois que
começou a escrever o livro. Antes de ser cortado pelos editores o título
era “55 fatos fundamentais e frequentemente esquecidos (e algumas
falácias)”, o que é uma descrição do conteúdo bem apropriada na visão do
autor: uma grande porção dos fatos é coisa que todo mundo envolvido em
engenharia de software deveria saber e não sabe, e quem já sabe acaba
esquecendo e não faz nada a respeito.

Lendo esse livrinho (é pequeno, não chega às 200 páginas), fiquei
surpreso encontrando respostas relevantes para perguntas que
aparentemente ninguém estaria prestando atenção, mas que estão
disponíveis de fato há algumas décadas! A leitura foi fascinante, mas
lendo me senti muito ignorante por ainda não ter lido um material
articulando essas coisas.

Espie só:

-   Propagandas exageradas (aka *hype*) são a praga da engenharia de
    software. A maioria dos melhoramentos envolvendo ferramentas e
    técnicas ajudam a aumentar entre 5% a 35% em produtividade e
    qualidade. Não obstante, esses melhoramentos são propagandeados como
    tendo benefícios de “uma ordem de magnitude”.**Adotar uma nova
    ferramenta ou técnica na verdade diminui a produtividade e qualidade
    do trabalho, inicialmente.** O benefício só é atingido depois da
    curva inicial de aprendizado, e portanto só vale a pena caso seu
    valor seja visto de forma realista e se tenha paciência ao medir os
    benefícios.
-   **O fator mais importante no trabalho com software não são as
    técnicas ou ferramentas usadas pelos desenvolvedores, e sim a
    qualidade dos próprios desenvolvedores.** Esse fato é sabido,
    evidenciado e documentado desde os anos 70. Apesar disso, muita
    gente decide "cortar custos" na hora de contratar desenvolvedores e
    depois tenta instigar qualidade com metodologias, processos e
    ferramentas. Seguidamente aparecem abordagens mesmo anti-pessoas,
    que tentam transformá-las em engrenagens numa linha de montagem, e
    serem facilmente substituíveis. Um exemplo famoso é o [CMM -
    Capability Maturity
    Model](https://en.wikipedia.org/wiki/Capability_Maturity_Model) do
    [Software Engineering Institute
    (SEI)](https://en.wikipedia.org/wiki/Software_Engineering_Institute),
    que se alastrou nas empresas públicas americanas (e vem fazendo o
    mesmo nas brasileiras...), que é baseado na percepção errônea de que
    o caminho para bom software é um bom processo. *Not so!* Mas veja o
    site do CMMI... O hype lá cativa qualquer gerente! :P
-   As duas maiores causas de projetos saírem do controle são
    <small>(a)</small> péssimas estimativas e <small>(b)</small>
    requisitos instáveis. Estimativas são frequentemente feitas pelas
    pessoas erradas (que não têm conhecimento o suficiente sobre como
    software é construído), no momento errado (no início do projeto,
    antes de qualquer trabalho pra descobrir exatamente o que será
    feito), nunca são ajustadas ao longo do projeto, e apesar disso tudo
    ainda são levadas a sério por todo mundo -- isso acaba gerando
    expectativas inalcançáveis desde o início, estresse desnecessário e
    moral-baixa das equipes. Já requisitos instáveis é um problema mais
    complicado, e a engenharia de software vem tentando abordagens
    diferentes em busca de soluções (depois de falhar miseravelmente
    tentando achar um jeito de obter um conjunto fechado de requisitos
    no início do projeto). Hoje, já é aceito como natural os requisitos
    sofrerem alterações ao longo do projeto, e a controvérsia está mais
    em como lidar nessas circunstâncias.
-   Reuso em pequena escala (*reuse-in-the-small*) existe há muito tempo
    (muito antes de OO, viu?), e é um problema resolvido desde os anos
    50. Reuso em grande escala (componentização de soluções de problemas
    genéricos) é um problema muito difícil, não-resolvido, mas que tem
    maior chance de funcionar para uma família de sistemas de um domínio
    específico. Linguagens de domínio específico (aka DSLs) são uma boa
    idéia, façamos mais coisas desse tipo!
-   **Para cada 25% de aumento na complexidade do problema, há um
    aumento de 100% na complexidade de sua solução.** Isso não é uma
    coisa a ser mudada, é só uma constatação de como as coisas são. Esse
    fato é muito bom saber porque, apesar de pouco conhecido, explica
    grande parte dos outros. Veja:
    1.  *Por que pessoas são tão importantes?* Porque é necessário
        habilidade e inteligência para superar complexidade.
    2.  *Por que estimar é tão difícil?* Porque as soluções são bem mais
        complicadas do que os problemas aparentam.
    3.  *Por que reuso em larga escala é tão difícil?* Porque grande
        complexidade significa grande diversidade de soluções.
    4.  *Por que existem tantas maneiras diferentes de abordar uma
        solução pra um problema?* Porque o espaço de soluções é bastante
        complexo.
    5.  *Por que conhecer uma solução existente é a tarefa mais difícil
        de manutenção de software?* Porque há muitas soluções possíveis
        para qualquer problema.
    6.  *Por que os softwares têm tantos erros?* Porque é difícil de
        fazer direito na primeira vez.
    7.  *Por que alguns pesquisadores de software recorrem a defesa de
        idéias não verificadas em vez de fazer pesquisas avaliativas que
        verifiquem suas declarações?* Talvez porque, no mundo de
        software complexo, é muito difícil fazer as pesquisas
        avaliativas tão necessárias e que deveriam anteceder as defesas
        de idéias.

Eu ainda não tinha visto tantas coisas relevantes -- e que muito
presenciei serem negligenciadas, às vezes por mim mesmo, sem saber como
agir -- compactadas em tão poucas páginas, e com dados reais, obtidos
usando medidas reais e úteis. Isso que a maioria das fontes do livro são
pré-2000 (o livro é de 2003), e tem bastante coisa interessante que é
pré-1980! Fenomenal... Me senti besta por ainda não ter ido atrás de
material como esse.

Comecei a montar a lista acima para funcionar como um "*sneak-peak"* do
material do livro, mas agora tô achando que o formato funciona legal
para apresentar um resumão dos pontos importantes do livro (e eu posso
ser mais preguiçoso, também :). Por isso, sigo com a lista de fatos:

-   Erros em requisitos são os mais caros de consertar quando o software
    já está em produção (e os mais baratos de consertar cedo no
    desenvolvimento), sendo os casos de “requisitos ausentes” os mais
    difíceis de todos.
-   Ocorre uma explosão de *requisitos derivados* (os requisitos para
    uma solução em particular) causada pela complexidade do processo de
    solução, que pode assumir proporções 50 vezes maior que os
    requisitos originais. Isso faz com que seja impossível de se obter o
    Santo Graal da rastreabilidade na prática.
-   Desenvolvedores alternam entre "modos" de análise e implementação
    quando o programa está sendo decomposto num nível de *primitivas*
    (unidades fundamentais conhecidas e facilmente codificadas) que o
    responsável pela análise domina. Se o implementador não é a mesma
    pessoa que fez a análise, as primitivas de cada um serão diferentes,
    e esse confronto gera uma série de problemas, tanto no caso do
    projetista ou no do implementador ser o profissional mais
    experiente. Por isso, é melhor que a pessoa que faça a análise seja
    a mesma que o implemente. Repetidamente se tenta praticar uma
    divisão de trabalho de análise e implementação, e repetidamente isso
    só causa mais problemas.
-   Remoção de erros é o que mais consome tempo do ciclo de vida do
    desenvolvimento de um software. **Inspeção rigorosa do código é a
    maneira mais efetiva de remoção de erros**, mas esse fato não é
    muito propagandeado porque inspeções exigem trabalho mental intenso,
    não existem fabricantes fazendo dinheiro com isso e ainda, da mesma
    forma que testes, às vezes são vistas como não essenciais. (Note que
    apesar dos grandes benefícios para remoção de erros, inspeções
    rigorosas não substituem os testes.)
-   Software que um programador típico acredita ter sido testado a
    fundo, teve apenas de 55% a 60% dos seus fluxos de lógica
    executados. Analisadores de cobertura ajudam a aumentar isso para
    entre 85 a 90%, mas é praticamente impossível atingir os 100%. Mesmo
    se fosse possível atingir os 100%, isso ainda não seria um critério
    suficiente para os testes. Em torno de 35% dos defeitos em software
    surgem de fluxos não-existentes e outros 40% resultam de uma
    combinação única de caminhos de lógica, portanto não seriam
    descobertos por uma cobertura de 100%.
-   Revisões têm aspectos tanto técnicos como sociológicos. Prestar
    atenção numa parte e não na outra é receita para o desastre. Por
    mais que se clame pela *“egoless programming”*, todos nós temos um
    investimento emocional e intelectual no resultado do nosso trabalho
    e estamos vulneráveis quando outros o estão revisando. E quando o
    resultado de um revisor é considerado pelos demais participantes
    duma revisão, o ego desse revisor também está na reta. Cabem algumas
    sugestões:
    1.  Não permita gerentes participar de revisões, eles tendem a
        revisar o produtor em vez do produto.
    2.  Não permita pessoas despreparadas participar, elas atrapalham os
        que estão preparados e causam digressões nos tópicos.
    3.  Separe o papel do líder da revisão do papel do produtor, para
        diminuir o envolvimento do ego do produtor.
-   Manutenção é uma solução, e não um problema. É a solução ao problema
    de não saber exatamente o que se quer construir na primeira vez, e
    por isso é um *big deal, dude, very important!* Ela consiste
    tipicamente de 40 a 80% de custos de software (média 60%), sendo por
    isso a fase mais importante. E 60% da manutenção consiste em
    melhorias, 17% apenas para correção de erros, 18% manutenção
    adaptiva (manter funcionando os recursos existentes em um ambiente
    novo), e os restantes 5% é o popular “outros” (manutenções
    preventivas -- refatorações -- estariam nesses 5%). Essa relação 60%
    do custo de construção de software é manutenção, e 60% da manutenção
    é adição de melhorias é chamada [regra
    60/60](http://programmer.97things.oreilly.com/wiki/index.php/The_60/60_Rule).
    Por fim, como manutenção é tão importante, talvez devesse ser
    ensinada antes de ensinar a produzir software (ensinar a ler antes
    de ensinar a escrever).
-   **Qualidade de software é uma coleção de atributos:**
    1.  <span style="text-decoration: underline;">Portabilidade</span> é
        sobre criar um produto de software facilmente movido para outra
        plataforma.
    2.  <span style="text-decoration: underline;">Confiabilidade</span>
        é sobre um software que faz o que devia fazer de forma
        confiável.
    3.  <span style="text-decoration: underline;">Eficiência</span> é
        sobre um software que economiza em tempo de execução e consumo
        de espaço.
    4.  <span style="text-decoration: underline;">Engenharia humana (ou
        usabilidade)</span> é sobre um software que é fácil e
        confortável de usar.
    5.  <span style="text-decoration: underline;">Testabilidade</span> é
        sobre um software que é fácil de testar.
    6.  <span
        style="text-decoration: underline;">Compreensibilidade</span> é
        sobre um software que é fácil para o mantenedor compreender.
    7.  <span
        style="text-decoration: underline;">Modificabilidade</span> é
        sobre um software que é fácil para o mantenedor modificá-lo.
-   Não existe uma ordem universal correta desses atributos que deve ser
    atingida, mas é importante que cada projeto tenha a sua lista
    priorizada.

Se você é como eu, os fatos acima devem ter ressonados fortemente com
sua experiência. Em vários pontos do livro, experimentei uma sensação de
alívio, constantando várias comichões minhas sendo coçadas, e numa forma
tão coerente, sensata, comedida, auto-avaliativa, madura...  —
<small>nuóssa, agora me apavorei comigo mesmo e a minha sacolinha de
adjetivos! :)</small>

Pois não se trata de um time de "desenvolvedores chorões e teimosos que
só querem bater contra a gerência", mas sim de evidência científica,
informações coletadas e analisadas de forma estudada e organizada,
enfim, fatos! Esquecidos frequentemente, sim, mas sempre serão fatos, e
não vão deixar de ser verdade mesmo que muitos na indústria e na
academia estejam em negação.

Bem, o livro tem bem mais coisas (tô pulando toda a parte específica de
codificação), pra quem quiser saber mais pode visitar os links no fim do
artigo ou então arranjar uma cópia do livro mesmo, que vale a pena. Só
quero ainda falar sobre algumas das falácias apresentadas no fim do
livro:

Falácia: *Você não pode gerenciar o que não pode medir.*  
**Errado!** Na verdade, fazemos isso o tempo todo. Gerenciamos um monte
de tipo de coisas que não temos como medir. Na vida diária mesmo,
inclusive, desde relações sociais até os hábitos de alimentação.
Gerenciamos até a pesquisa do câncer. Gerenciamos análise e projeto de
software, que é uma tarefa essencialmente criativa. Gerenciamos muitas
coisas que são intelectuais ou mesmo criativas, sem nenhuma idéia que
números deveríamos ter pra nos guiar. Gerentes que trabalham com bom
conhecimento tendem a gerenciar qualitativamente, e não
quantitativamente.  
Todavia, não é porque esse dito é uma falácia que devemos rejeitar a
mensagem que ele traz. Afinal, gerenciar tendo em mãos alguns dados
úteis é mais fácil que na ausência deles, e por isso é muito importante
para o gerenciamento de software medir as coisas úteis.  
Boa capacidade de julgamento é vital.

Falácia: *Você consegue "gerenciar qualidade” para um produto de
software (manage quality into a software product)*  
**Errado também!** Aqui é basicamente uma reprise da afirmação anterior
sobre qualidade ser composta de alguns atributos: portabilidade,
confiabilidade, usabilidade, eficiência, testabilidade,
compreensibilidade e modificabilidade. **Todos esses atributos da
qualidade de software têm aspectos profundamente técnicos, e portanto
<span style="text-decoration: underline;">qualidade é uma realização
técnica</span>.** Não funciona marketar qualidade, ou “metodologizar”
qualidade  -- as abordagens dos gerentes para atingir qualidade, que
tendem a ser um tiro no pé, alienando os profissionais técnicos. E não
ajuda que o inimigo número um de qualidade na maioria dos projetos é a
pressão do cronograma. A gerência fica querendo enfiar “qualidade” com
uma mão e tirar com a outra!
[![TQM-wont\_work](https://eljunior.files.wordpress.com/2012/12/tqm-wont_work.jpg?w=300)](https://eljunior.files.wordpress.com/2012/12/tqm-wont_work.jpg)  
Note que a falácia aqui é que qualidade seja um trabalho da gerência. A
gerência tem um papel muito importante em atingir qualidade: estabelecer
a cultura de prioridade em primeiro lugar, remover barreiras que impedem
os técnicos de instituir qualidade, contratar pessoas de qualidade (a
*ultimate* melhor maneira de atingir qualidade no produto), e sair do
caminho dessas pessoas de qualidade, permitindo-as que façam o que
queriam fazer o tempo todo: construir algo que eles possam se orgulhar.

**Ler mais:**

-   Post do Jeff Atwood com a lista completa de fatos e falácias (em
    inglês) -- <small>o texto que me instigou a comprar o livro:</small>
    <https://www.codinghorror.com/blog/2008/03/revisiting-the-facts-and-fallacies-of-software-engineering.html>
-   *"You can indeed manage what you can’t measure"*:
    -   <http://www.galorath.com/wp/you-can-manage-what-you-cant-measure.php>
    -   <http://blogs.hbr.org/davenport/2010/10/what_cant_be_measured.html>
    -   <http://corporatedeathspiral.blogspot.com.br/2009/11/managing-what-you-cant-measure.html>
-   Série de posts em português discutindo os fatos e falácias do livro:
    -   <http://mr-bin.blogspot.com.br/2011/03/fatos-e-falacias-de-engenharia-de.html>
    -   <http://mr-bin.blogspot.com.br/2011/03/fatos-e-falacias-de-engenharia-de_18.html>
    -   <http://mr-bin.blogspot.com.br/2011/04/fatos-e-falacias-de-engenharia-de.html>
    -   <http://mr-bin.blogspot.com.br/2011/09/fatos-e-falacias-de-engenharia-de.html>
    -   <http://mr-bin.blogspot.com.br/2011/11/fatos-e-falacias-de-engenharia-de.html>

