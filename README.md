## NOTE
This is a fork of [BlueAlmost/gnuzplot](https://github.com/BlueAlmost/gnuzplot), which I did for hobby/educational purposes, so all the credit for the core functionality of this project shall go to them.

I decided to fork it instead of creating pull requests, because I want to modify source code according to my own vision and preferences.

I intend to use this project for my computational mathematics homework, so I'm going to add more features as soon as I need them.

## So far implemented features of this fork 
### (I hope this list won't always be this pathetically short)
* build.zig.zon for zig package manager installation
* Splot with nonuniform matrix

## Installation
Project can be installed with standard zig package manager method:

```sh
zig fetch --save git+https://github.com/ultragreed/gnuzplot
```

Then in your `build.zig` file you can import it to your modules:

```zig
const gnuzplot = b.dependency("gnuzplot", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("gnuzplot", gnuzplot.module("gnuzplot"));
```

Given that `exe` is your library/executable. 

Note that you can actually use any string as first argument of the `.addImport()`. This is the name you will then use with `@import()`.

## Usage
Initialize plotting object with 

```zig
var plt = try Gnuzplot.init(allocator);
```

The only allocation happens during initialization of child gnuplot process.

Most of the functions accept **anytype** object, consisting of single or multiple sets of arguments. Each set describes one plot:
```zig
try plt.plotXY(.{
    plot_data.spx1, plot_data.spy1, "title 'x' with linespoints lw 1 pt 9 ps 2.3",
    plot_data.spx2, plot_data.spy2, "title 'x' with linespoints lw 2 pt 7 ps 2.3",
});
```

One can explore more examples below. Also take a look into *example/examples.zig*. 

There aren't so many bindings of the huge gnuplot project implemented so far, so you can use `plt.cmd` or `plt.cmdfmt` in case you need more:

```zig
try plt.cmd("help help");
try plt.cmdfmt("{s}\n", .{"help help"});
```


# gnuzplot
***Zig*** bindings for data plotting using gnuplot (hence the name here with a "z" inserted, yielding gnu**z**plot)

* **Basic idea:**    allow plotting of data vectors from within zig (pipe into child process of gnuplot)

* **Demos:**         one can manually clone the repo and run `zig build run` to see simple examples  
 
* **Motivation:**    visualization of vectors or other data while they undergo manipulation within zig

* **Requirements:**    local installation of [gnuplot](https://www.gnuplot.info)

* **Availability:**    has been developed/tested in GNU/Linux environment (Gentoo), functionality on other systems not tested.

------------------

# Examples:
All of the following examples can be found in example/examples.zig

------------------

![fig_1](https://user-images.githubusercontent.com/100024520/177419277-39fe3467-a5f8-4241-8f89-823acdc846f3.png)

```zig
try plt.gridOn();
try plt.title("A simple signal from JSON data file");
try plt.plot(.{plot_data.s, "title 'sin pulse' with lines ls 5 lw 1"});
```
  
------------------

![fig_2](https://user-images.githubusercontent.com/100024520/177419281-191554f6-aa3c-4f21-9772-75adbcbfab8a.png)

```zig
try plt.gridOn();
try plt.title("now with line and point");
try plt.plot(.{plot_data.c, "title 'sin pulse' with linespoints ls 3 lw 2 pt 7 ps 2"});
```

------------------

![fig_3](https://user-images.githubusercontent.com/100024520/177419283-c919e99a-30d3-4a9c-8113-9646d21d352b.png)

```zig
try plt.gridOff();
try plt.title("Two other signals with transparency");
try plt.plot(.{
    plot_data.s, "title 'sin' with lines ls 14 lw 2",
    plot_data.n, "title 'sin in noise' with lines ls 25 lw 2"
});
```
    
------------------   

![fig_4](https://user-images.githubusercontent.com/100024520/177419285-aa173356-edcc-432a-9260-b75cd1b738f8.png)

```zig
try plt.title("x vs y line plot");
try plt.plotXY(.{
    plot_data.spx1, plot_data.spy1,"title 'x' with linespoints lw 1 pt 9 ps 2.3",
    plot_data.spx2, plot_data.spy2,"title 'x' with linespoints lw 2 pt 7 ps 2.3",
});
```
    
 ------------------
 
![fig_5](https://user-images.githubusercontent.com/100024520/177419286-c9e26ccb-3a3e-4b9d-9af7-a19ecfdd6451.png)

```zig
try plt.title("x vs y scatter plot with transparency");
try plt.plotXY(.{plot_data.bx, plot_data.by, "title 'x' with points ls 28 pt 7 ps 5"});
```

 ------------------
 
![fig_6](https://user-images.githubusercontent.com/100024520/177419291-99876af8-e110-48a9-9208-135c1bcaf224.png)

```zig
try plt.gridOn();
try plt.title("bar plot");
try plt.bar(.{plot_data.x, 0.75, "title 'x' ls 7 "});
```
    
 ------------------
 
![fig_7](https://user-images.githubusercontent.com/100024520/177419293-99b3bd51-bf6a-4808-aa50-bd5efd28cc38.png)

```zig
try plt.gridOn();
try plt.title("shared bar plot with three vectors");
try plt.bar(.{
    plot_data.x, 0.5, "title 'x' ls 33 ",
    plot_data.y, 0.5, "title 'y' ls 44 ",
    plot_data.z, 0.5, "title 'z' ls 55 "
});
```
    
 -------------------
 
  ![fig_8](https://github.com/user-attachments/assets/039ac414-5c8e-4fb0-ba2e-9b428cf85d7d)

 ```zig
try plt.title("splot");
try plt.splot(.{
    plot_data.splot_x,
    plot_data.splot_y,
    plot_data.splot_z,
    "with lines title 'z(x, y)'",
});
 ```
    
 ------------------ 
