Title: Programando Erlang - 1 de Any
Date: 2014-04-05 23:35
Author: Elias Dorneles
Slug: Programando-Erlang---1-de-Any

Na virada do ano, uma das minhas resoluções para 2014 foi a de que este ano
aprenderia [Erlang](http://www.erlang.org/).  Eu queria brincar com alguma
linguagem que usasse ideias diferentes das que uso no trabalho e que me
ensinasse mais do que simplesmente outro jeito de escrever os programas que já
sei.

Como eu gostei de ler as ideias do [Joe Armstrong](http://joearms.github.io/)
no livro [Coders at Work](http://www.codersatwork.com/), e as [descrições de
Erlang](http://en.wikipedia.org/wiki/Erlang_(programming_language)) na Internet
me deixaram curioso, resolvi que em 2014 eu iria aprender Erlang. E assim,
decidi por comprar logo o livro [Programming
Erlang](http://pragprog.com/book/jaerlang2/programming-erlang), escrito pelo
próprio Joe, e tentar aprender por ele.

Ainda não terminei de ler o livro, estou curtindo o aprendizado, acho que foi
uma boa escolha de linguagem “extra” pra aprender. Mas como o livro fala sobre
bastante coisa, resolvi escrever alguma coisa logo porque se deixar para
escrever sobre o livro inteiro a tarefa vai ficar grande demais e eu vou fugir
correndo com medo dela.

Então...  Erlang!

É uma linguagem divertida. =)

Erlang é uma linguagem funcional com tipagem dinâmica, de propósito geral,
focada em facilitar o desenvolvimento de programas concorrentes e que roda em
uma máquina virtual própria (também chamada
[BEAM](http://www.erlang-factory.com/upload/presentations/708/HitchhikersTouroftheBEAM.pdf)).

Mas Erlang é mais do que uma linguagem, podemos dizer que Erlang é todo um
ambiente diferente. A VM de Erlang lembra um sistema operacional em muitas
formas, possuindo seu próprio shell, seu próprio gerenciador de processos, seu
esquema de atualização sem precisar parar nenhum processo e seus [mecanismos
disponíveis para comunicação entre
processos](http://pt.wikipedia.org/wiki/Comunica%C3%A7%C3%A3o_entre_processos).

Um processo Erlang não é nem um processo do sistema operacional nem uma thread:
é um [processo
leve](http://en.wikipedia.org/wiki/Erlang_(programming_language)#Concurrency_and_distribution_orientation),
muito mais leve que threads. A criação de um novo processo é praticamente
gratuita -- pode-se dizer que criar um novo processo em Erlang é tão comum e
tão sossegado quanto instanciar um novo objeto em Java.

Em Erlang, é idiomático encapsular funcionalidade em processos, e é comum um
sistema ter milhares desses processos concorrentes, cada um com sua
responsabilidade. Assim, esses processos encapsulando funcionalidades são
análogos a[serviços em uma arquitetura orientada a
serviços](http://en.wikipedia.org/wiki/Service_(systems_architecture)), só que
em Erlang eles aparecem numa forma bem natural na linguagem e mais integrada ao
ambiente.

Aqui, permita-me apresentar algumas coisinhas da linguagem pra você, bem
rapidão. Para acompanhar, [instale Erlang](http://www.erlang.org/download.html)
(no Ubuntu: `sudo apt-get install erlang`).

### Super-quick-little-taste-of-Erlang

Veja o seguinte esqueleto de um programa concorrente em Erlang:

[!["Esqueleto de programa Erlang"](http://2.bp.blogspot.com/-HmS5hqh97EA/U0D7Y5iIeII/AAAAAAAAAtk/SVLNHGSIVHk/s1600/erlang-loop-menor.png)](http://2.bp.blogspot.com/-HmS5hqh97EA/U0D7Y5iIeII/AAAAAAAAAtk/SVLNHGSIVHk/s1600/erlang-loop-menor.png)

Note a recursão na função `loop`: é assim que se faz processos iterativos
(loops) em Erlang, que não tem sintaxe especial para isso. O compilador
implementa a otimização de “[recursão de
cauda](http://pt.wikipedia.org/wiki/Recursividade_(ci%C3%AAncia_da_computa%C3%A7%C3%A3o)#Fun.C3.A7.C3.B5es_recursivas_em_cauda)”
([tail recursion](http://en.wikipedia.org/wiki/Tail_call)) para fazer uma
função escrita de maneira recursiva executar de forma iterativa  -- isto é, sem
re-chamar a função aumentando a[pilha de
chamada](http://pt.wikipedia.org/wiki/Pilha_de_chamada) ([call
stack](http://en.wikipedia.org/wiki/Call_stack)).  

Você pode testar esse código colocando-o em um arquivo `esqueleto.erl` e chamá-lo
do shell Erlang, conforme a sessão abaixo:


     $ erl
     Erlang R16B01 (erts-5.10.2) [source] [64-bit] [smp:4:4] [async-threads:10] [kernel-poll:false]
     
     
     Eshell V5.10.2  (abort with ^G)
     1> c(esqueleto).
     {ok,esqueleto}
     2> Pid = esqueleto:start().
     <0.41.0>
     3> Pid ! "alo!".
     Received: "alo!"
     "alo!"
     4> Pid ! 1234.
     Received: 1234
     1234
     5> Pid ! {teste, com, uma, tupla, 123, "ola"}.
     Received: {teste,com,uma,tupla,123,"ola"}
     {teste,com,uma,tupla,123,"ola"}
     6>


Note os pontos finais no fim de cada comando: o comando não roda se você
esquecer deles. Em Erlang, o ponto `.` separa comandos e declarações, o
ponto-e-vírgula `;` separacláusulas, e a vírgula `,` separa expressões.

A primeira linha, `c(esqueleto).`  manda compilar o módulo no arquivo
`esqueleto.erl`.

Na segunda linha, `Pid = esqueleto:start().` aciona a função `start()` do módulo
`esqueleto`, que vai gerar um novo processo e retornar o identificador do
processo (em inglês, process identifier), que armazenamos na variável `Pid`. 

A seguir, na terceira linha usamos o comando!  para envio de mensagens em
Erlang, enviando a mensagem“alo!” para o processo criado na linha anterior,
identificado porPid.  O comando `receive` da função `loop()`  vai receber a
mensagem e executar o código que imprime a mensagem na tela. A mensagem aparece
repetida na tela porque o retorno do comando de envio `Pid ! Mensagem` é a
mensagem enviada, e o shell sempre imprime o retorno do último comando
executado.

As linhas seguintes apenas repetem o mesmo feito da linha anterior, com outras
mensagens diferentes (um inteiro e uma tupla contendo átomos, inteiros e
strings).

O comando `receive`  tem algumas habilidades especiais: além de bloquear a
execução do código até o processo receber uma mensagem (que também pode ter um
timeout  definido), ele pode selecionar o bloco de código a ser executado
dependendo da forma ou conteúdo da mensagem, com o mecanismo chamado de
[pattern matching](http://en.wikipedia.org/wiki/Pattern_matching) (ou,
[casamento de
padrões](http://pt.wikipedia.org/wiki/Casamento_de_padr%C3%B5es)). 

Por exemplo, usando pattern matching, podemos alterar o comando  `receive` da
função  `loop()`   para executar um código diferente caso receba a mensagem
`"alo!"`: 

    loop() ->
        receive
            "alo!" ->
                io:format("Alooooow, galerinha da paaishhh!"),
                loop();
            Any ->
                io:format("Received: ~p~n", [Any]),
                loop()
        end.

Se você repetir os passos anteriores com esse novo código, receberá uma
resposta mais animada quando enviar a mensagem `"alo!"`. =)

Nesse exemplo, o padrão casado foi o conteúdo da mensagem, isto é, a string
`"alo!"`. Mas o mecanismo permite fazer vários tipos de verificações: você
pode, por exemplo, verificar se a mensagem é um número ou uma tupla, se é uma
tupla contendo um determinado elemento, se é uma lista com tantos elementos,
etc.

Quando alguém mais acostumado ao paradigma imperativo se depara com a ideia de
pattern matching (que existe em outras linguagens além de Erlang), usualmente
acha útil [pensar nele como um "switch-case em
esteróides"](http://stackoverflow.com/questions/2502354/what-is-pattern-matching-in-functional-languages),
uma espécie de Super Estrutura Condicional.

Em Erlang, todavia,pattern matching (ou casamento de padrões) aparece em mais
do que estruturas condicionais.

De fato, na expressão:

    X = 1.



o `=` (igual) é um acionamento do operador depattern matching de Erlang --
diferente de outras linguagens em que o igual é um operador de
[atribuição](http://pt.wikipedia.org/wiki/Atribui%C3%A7%C3%A3o_(computa%C3%A7%C3%A3o)).
Erlang não tem operador atribuição, que usualmente permite definir e redefinir
o conteúdo de variáveis.

O que acontece aqui é que o [operador de pattern
matching](http://www.erlang.org/doc/reference_manual/patterns.html) liga um
valor a uma variável quando esta ainda não tem nenhum valor associado (isto é,
quando se trata de uma [variável
livre](http://pt.wikipedia.org/wiki/Vari%C3%A1veis_livres_e_ligadas), ou
*unbound variable*).

Na próxima vez que a variável for referenciada, ela terá o valor "casado"
(matched) anteriormente, veja:


    1> A.
    * 1: variable 'A' is unbound
    2> A="oi".
    "oi"
    3> A.
    "oi"
    4>

Uma vez ligada, a variável só casará com o valor original, e nunca mais com
outro. Caso tente casar a variável com outro valor (pensando que funcionaria
como atribuição), você obterá um erro avisando que falhou o casamento do
padrão:

    4> A = "alô". 
    ** exception error: no match of right hand side value "alô"

Isto porque em Erlang, as variáveis são imutáveis para o contexto local.  Outra
forma de dizer é: em Erlang, as variáveis são de atribuição única (single
assignment variables).  Uma vez atribuído um valor a uma variável, você não
pode alterá-lo -- como demonstrei acima.

Isto parece estranho no começo, para quem está acostumado com o paradigma
imperativo. Pensando bem, é a mesma estranheza que a gente sente quando aprende
a programar e é exposto a variáveis e atribuição pela primeira vez (“como
assim, x = x + 1?).  Faz mais sentido pensar nas variáveis de Erlang como as
variáveis da Matemática, em que o valor de um nome é sempre o mesmo.”

A imutabilidade de variáveis tem como consequência algumas coisas
interessantes:

- força você a criar novas variáveis em algumas situações, mesmo que esteja com
  pouca criatividade para dar um nome decente (no livro mesmo tem alguns
  exemplos com `Word1`, `Word2` -- o que é meio feio)

- evita alguns tipos debugs e simplifica a depuração, pois aumenta a
  previsibilidade da execução do código (isto é, você pode confiar que o valor
  de uma variável não vai mudar)

- facilita a escrita de programas concorrentes e permite que sejam rodados em
  paralelo, pois evita uma cacetada de problemas de memória compartilhada


E esta última consequência compensa as dificuldades de dar nomes às variáveis.
Porque escrever programas multi-thread é difícil de fazer direito (você precisa
se preocupar com
[sincronização](http://en.wikipedia.org/wiki/Synchronization_(computer_science))
de processos e de memória), e o jeito Erlang de escrever programas concorrentes
que se comunicam via envio de mensagens (o [modelo de
atores](http://c2.com/cgi/wiki?ActorsModel)) simplifica as coisas, de forma que
os programas são sempre paralelizáveis.

Isso faz com que aplicações escritas em Erlang escalem mais fácil do que
aplicações escritas em outras linguagens. Claro que vários problemas de
escalabilidade se manterão, principalmente os relacionados a hardware e
infraestrutura, mas problemas de software tendem a ser resolvidos mais fácil
com Erlang.

De fato, Erlang vem de fábrica com mecanismos de clusterização, e você pode
facilmente iniciar nós de um cluster em algumas máquinas e disparar chamadas
remotas de um nó para outro.

Para um exemplo rápido, inicie um nó do cluster em um terminal, dando um nome:

    $ erl -sname lennon@localhost
    Erlang R16B01 (erts-5.10.2) [source] [64-bit] [smp:4:4] [async-threads:10] [kernel-poll:false]


    Eshell V5.10.2  (abort with ^G)
    (lennon@localhost)1> 


Em outro terminal, inicie outro nó e faça uma chamada remota ao nó anterior:

    $ erl -sname mccartney@localhost
    Erlang R16B01 (erts-5.10.2) [source] [64-bit] [smp:4:4] [async-threads:10] [kernel-poll:false]


    Eshell V5.10.2  (abort with ^G)
    (mccartney@localhost)1> rpc:call(lennon@localhost, file, list_dir, ["/"]).
    {ok,["var","tmp","mnt","lib","boot","lib32","vmlinuz",
         "proc","media","bin","lib64","sys","opt","sbin","srv",
         "root","dev","usr","initrd.img","lost+found","cdrom","home",
         "vmlinuz.old","run","etc","initrd.img.old"]}
    (mccartney@localhost)2>

O argumento `-sname` faz com que Erlang inicie um nó com o nome passado (note
como o nome do nó é mostrado no prompt). No comando que executamos no segundo
nó (`mccartney@localhost`) usamos a função [call do módulo
`rpc`](http://erlang.org/doc/man/rpc.html) para acionar uma função remotamente
em outro nó e obter o resultado -- neste caso, a função `os:listdir("/")` para
retornar a lista de arquivos do diretório raiz.

E tudo com código da distribuição padrão. (Try that in Java, biátch!)

Bom, tentei mostrar algumas coisas interessantes da linguagem aqui, mas Erlang
tem muito a oferecer ainda. Ela tem outros [tipos de dados
interessantes](http://www.erlang.org/doc/reference_manual/data_types.html)
(átomos,
[binaries](http://www.erlang.org/doc/efficiency_guide/binaryhandling.html),
tuplas, [records](http://www.erlang.org/doc/reference_manual/records.html), e
na [versão R17](http://www.erlang.org/news/67) terá
[maps](http://www.erlang.org/eeps/eep-0043.html)), um [mecanismo próprio de
comunicação com outros processos do sistema
operacional](http://www.erlang.org/doc/reference_manual/ports.html), permite a
[especificação opcional de tipos para
funções](http://www.erlang.org/doc/reference_manual/typespec.html), um [banco
de dados para aplicações
distribuídas](http://www.erlang.org/doc/man/mnesia.html), vem com ferramentas
de fábrica para análise estática de código, depuração e profiling e com um
[conjunto de bibliotecas e funções para aplicações tolerante a falhas e
distribuídas](http://learnyousomeerlang.com/what-is-otp).

Só tem dois problemas de usabilidade que me incomodam um pouco:

- Nem todos os comandos ou exemplos de código funcionam no shell. Algumas
  funcionalidades só estão disponíveis no shell, e outras apenas em módulos
  compilados ([criar funções no
  shell](http://stackoverflow.com/questions/2065990/defining-erlang-functions-in-the-shell),
  por exemplo). Isso é uma espécie de “bug conhecido”: [Joe Armstrong, o criador
  da linguagem, conta que seus cabelos embranqueceram de tanto explicar por que
  a implementação ficou desse
  jeito](http://joearms.github.io/2013/05/31/a-week-with-elixir.html).

- O shell não tem histórico persistente, e não suporta atalhos comuns em
  aplicações da linha de comando que usam a [GNU
  Readline](http://en.wikipedia.org/wiki/GNU_Readline).  Parece que o esquema
  de IO do shell Erlang é meio complicado de manter -- no GitHub tem [um
  projeto que adiciona um histórico persistente
  básico](https://github.com/ferd/erlang-history), mas o FAQ não é muito
  encorajador.

O resto é fantástico. =)

Caso você tenha ficado curioso, pode querer conferir o livro [Learn You Some
Erlang](http://learnyousomeerlang.com/) -- não li, mas já tirei algumas dúvidas
nele caindo de buscas do Google e pareceu muito bom. Have a nice journey!  :)

Valeu pela revisão, Fredi e Denise.
