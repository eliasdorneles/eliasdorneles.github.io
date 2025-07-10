Title: Introducing MooMoolah -- simple monthly budget planning
Date: 2025-07-10 21:58:39
Author: Elias Dorneles


I wanted a simple, lightweight way to keep track of my money, but without the
tedious task of logging every single expense.

What I wanted was something that could take my typical income and most important recurring expenses, then give me a rough, actionable forecast for the months ahead.

I tried using a Google Sheets spreadsheet, but I got tired of
fighting with it, trying to get it to do what I needed.

The issue is that my expenses aren't always monthly or yearly. I've got bills
that hit every 3 months, others every 4 months. Finding a tool that was both
simple and could handle this kind of varied recurrence was... impossible?

Since nothing quite fit the bill, I decided to build my own.

Well, [here it is!](https://github.com/eliasdorneles/moomoolah).

### Enter MooMoolah 🫰

I named it MooMoolah, it's open source, it works locally, inside your terminal,
privately and safely, like most apps that I love.
It does exactly what I needed it to do -- it might just as well work for you too!

Here’s what it looks like when you're adding an expense:


<center>

<img src="https://raw.githubusercontent.com/eliasdorneles/moomoolah/refs/heads/main/demo_add_expense.svg" width="600" />

</center>

And here's the main screen, giving you a clear forecast for the next 12 months,
plus a look back at the last 3:

<center>

<img src="https://raw.githubusercontent.com/eliasdorneles/moomoolah/refs/heads/main/demo_main_screen.svg" width="600" />

</center>

You can install it with: `pip install moomoolah`.

And then use it by running:

    moomoolah

(Optional: You can also specify a path to a JSON file if you want to store your
data in a custom location; otherwise, it'll use a default spot.)

For all the nitty-gritty details, check out the
[README](https://github.com/eliasdorneles/moomoolah/blob/main/README.md) on GitHub.

