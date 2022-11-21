
import PySimpleGUI as gui
import math
import io
from PIL import Image
import matplotlib.pyplot as plot
import lupa

import sys

if (len(sys.argv)!=2) and (len(sys.argv)!=3):
  print("Usage: show_substance.py lua_data_dir [image_size]")
  exit();

directory = sys.argv[1]
image_size = 512
if len(sys.argv)>2:
  image_size = int(sys.argv[2])

lua = lupa.LuaRuntime(unpack_returned_tuples=True)
print("Using file: \"{}/python_api.lua\")".format(directory))
lua.execute("dofile(\"{}/python_api.lua\")".format(directory))

default_values = {
    "dH0" : "",
    "H_coef" : "",
    "dS" : ""
  }

green = default_values.copy()
blue = default_values.copy()
red = default_values.copy()

def calc_deltaG(name, T, p, V):
  return lua.eval("calc_deltaG(\"{}\", {}, {}, {})".format(name, T, p, V))

def calc_p(axis, y, size):
  y = size - y
  if axis["p_linear"]:
    return axis["p_from"]+(axis["p_to"]-axis["p_from"])*y/size
  else:
    return 10**(math.log10(axis["p_from"])+(math.log10(axis["p_to"])-math.log10(axis["p_from"]))*y/size)
  
def calc_T(axis, x, size):
  if axis["T_linear"]:
    return axis["T_from"]+(axis["T_to"]-axis["T_from"])*x/size
  else:
    return 10**(math.log10(axis["T_from"])+(math.log10(axis["T_to"])-math.log10(axis["T_from"]))*x/size)

def getPicture(axis, name_g, name_b, name_r, size):
  lua.eval("reload(\"{}\")".format(directory))
  
  image = Image.new(mode="RGB", size=(size,size))
  
  pic = [0]*size*size
  
  if axis["gradular_colors"]:
    data_g = [0]*size*size
    data_b = [0]*size*size
    data_r = [0]*size*size
    for y in range(size):
      # preasure axis
      xy_p = calc_p(axis, y, size)
      for x in range(size):
        # temperature axis
        xy_T = calc_T(axis, x, size)
        
        index = y*size+x
        
        
        data_g[index] = abs(calc_deltaG(name_g, xy_T, xy_p, xy_T))
        data_b[index]  = abs(calc_deltaG(name_b, xy_T, xy_p, xy_T))
        data_r[index]  = abs(calc_deltaG(name_r, xy_T, xy_p, xy_T))
        
    min_dG = min([min(data_g),min(data_b),min(data_r)])
    max_dG = max(max(data_g),max(data_b),max(data_r))
    diff_dG = max_dG - min_dG
    
    for y in range(size):
      # preasure axis
      for x in range(size):
        # temperature axis
        
        index = y*size+x
        
        xy_g = round((data_g[index]-min_dG)/diff_dG*255)
        xy_b = round((data_b[index]-min_dG)/diff_dG*255)
        xy_r = round((data_r[index]-min_dG)/diff_dG*255)
        
        line = False
        
        if (index>size):
          if (data_g[index]>=data_b[index]) and (data_g[index-size]<data_b[index-size]):
            line = True
          if (data_g[index]<=data_b[index]) and (data_g[index-size]>data_b[index-size]):
            line = True
          if (data_g[index]>=data_r[index]) and (data_g[index-size]<data_r[index-size]):
            line = True
          if (data_g[index]<=data_r[index]) and (data_g[index-size]>data_r[index-size]):
            line = True
          if (data_b[index]>=data_r[index]) and (data_b[index-size]<data_r[index-size]):
            line = True
          if (data_b[index]<=data_r[index]) and (data_b[index-size]>data_r[index-size]):
            line = True
        
        if (index%size>1):
          if (data_g[index]>=data_b[index]) and (data_g[index-1]<data_b[index-1]):
            line = True
          if (data_g[index]<=data_b[index]) and (data_g[index-1]>data_b[index-1]):
            line = True
          if (data_g[index]>=data_r[index]) and (data_g[index-1]<data_r[index-1]):
            line = True
          if (data_g[index]<=data_r[index]) and (data_g[index-1]>data_r[index-1]):
            line = True
          if (data_b[index]>=data_r[index]) and (data_b[index-1]<data_r[index-1]):
            line = True
          if (data_b[index]<=data_r[index]) and (data_b[index-1]>data_r[index-1]):
            line = True
        
        if line:
         xy_g = 255
         xy_b = 255
         xy_r = 255
        
        # two substances
        # k = A*T*const*e**(-dG/RT)
        # nepocitat pomery a kombinace barev?
        pic[index] = (int(xy_r), int(xy_g), int(xy_b))
  else:
    for y in range(size):
      # preasure axis
      xy_p = calc_p(axis, y, size)
      for x in range(size):
        # temperature axis
        xy_T = calc_T(axis, x, size)
        
        xy_r = xy_g = xy_b = 0
        dG_g = abs(calc_deltaG(name_g, xy_T, xy_p, xy_T))
        dG_b = abs(calc_deltaG(name_b, xy_T, xy_p, xy_T))
        dG_r = abs(calc_deltaG(name_r, xy_T, xy_p, xy_T))
          
        # C_1 = e^((2*dG)/(R*T))/(e^((2*dG)/(R*T))+1)

        if dG_b<dG_g and dG_r<dG_g:
          xy_g = 255
        elif dG_g<dG_b and dG_r<dG_b:
          xy_b = 255
        else:
          xy_r = 255
        # two substances
        # k = A*T*const*e**(-dG/RT)
        # nepocitat pomery a kombinace barev?
        pic[y*size+x] = (int(xy_r), int(xy_g), int(xy_b))
  
  image.putdata(pic)
  virtual_file = io.BytesIO()
  image.save(virtual_file, format = "png")
  return virtual_file.getvalue()

image = Image.new(mode="RGB", size=(image_size,image_size))

virtual_file = io.BytesIO()

image.save(virtual_file, format = "png")

def createKey(prefix, key):
  return "-{0}_{1}-".format(prefix, key)

def addPhase(layout, label, name, prefix):
  phase = [
      # loaded name
      [gui.Text("Key:"), gui.Input("",key=createKey(prefix, "key"))],
      [gui.Button("Load "+name)],
      # parameters
      [gui.Table([["Not loaded", "Not loaded"]], headings=["Parameter","Value"], key=createKey(prefix, "params"))]]
  
  layout[0].append(gui.Frame(label, phase))

def loadPhase(window, key, prefix):
  phase_params = []
  lua.eval("reload(\"{}\")".format(directory))
  table = lua.eval("get_substance(\"{}\")".format(key))
  if table == None:
    phase_params.append(["Not loaded", "Not loaded"])
  else:
      for key in list(table):
        val = table[key]
        if (type(val)==type("a")) or (type(val)==type(5)) or (type(val)==type(5.5)):
          phase_params.append(["{}".format(key),"{}".format(val)])
  window["-{}_params-".format(prefix)].update(phase_params)

infoColumn = [[gui.Text("Temperature:"), gui.Input("", key="-T_set-"), gui.Text("K")],
              [gui.Text("Preasure:",), gui.Input("", key="-p_set-"), gui.Text("Pa")],
              [gui.Button("Recalculate")],
              [gui.Text("Key : ", key="-info_g-")],
              [gui.Text("Key : ", key="-info_b-")],
              [gui.Text("Key : ", key="-info_r-")],
              [gui.Text("Constant temperature: "), gui.Input("300", key="-T_const-")],
              [gui.Text("Constant preasure: "), gui.Input("10e5", key="-p_const-")],
              [gui.Button("Plot dG for const T"), gui.Button("Plot dG for const p")] ]

layout = [  [],
            [gui.Checkbox("Gradular colors", key="-grad_cols-")],
            #[gui.Image(size=(image_size,image_size), key="-img-", data=virtual_file.getvalue(), enable_events=True)],
            [gui.Graph((image_size,image_size), (0,image_size), (image_size,0), key="-img-", enable_events=True),gui.Column(infoColumn)],
            [gui.Text("Preasure: From "),gui.Input("10e3", key="-p_from-"),gui.Text(" to "),gui.Input("10e9", key="-p_to-"),gui.Text(" Pa "),gui.Checkbox("Linear axis:", key="-p_linear-")],
            [gui.Text("Temperature: From"),gui.Input("0", key="-T_from-"),gui.Text(" to "),gui.Input("3000", key="-T_to-"),gui.Text(" K "),gui.Checkbox("Linear axis:", key="-T_linear-", default=True)],
            [gui.Button("Update Picture"),gui.Button("Print substances"),gui.Button("Exit")]  ]

addPhase(layout, "Green", "green", "g")
addPhase(layout, "Blue", "blue", "b")
addPhase(layout, "Red", "red", "r")

window = gui.Window("Show substance",layout, finalize=True)

while True:
  event, values = window.read()
  if event in (gui.WIN_CLOSED, "Exit"):
    break
  elif event=="Update Picture":
    axis = {
            "p_from": float(values["-p_from-"]),
            "p_to": float(values["-p_to-"]),
            "p_linear": values["-p_linear-"],
            "T_from": float(values["-T_from-"]),
            "T_to": float(values["-T_to-"]),
            "T_linear": values["-T_linear-"],
            "gradular_colors": values["-grad_cols-"],
        }
    try:
      image_data = getPicture(axis, values["-g_key-"], values["-b_key-"], values["-r_key-"], image_size)
      #window["-img-"].update(data=image_data)
      window["-img-"].draw_image(data=image_data, location=(0, 0))
      window.refresh()
    except Exception as err:
      print("Update picture error:\n", err)
  elif event=="Print substances":
    lua.eval("print_substances()")
  elif event=="Load green":
    loadPhase(window, values["-g_key-"], "g")
  elif event=="Load blue":
    loadPhase(window, values["-b_key-"], "b")
  elif event=="Load red":
    loadPhase(window, values["-r_key-"], "r")
  elif event=="-img-":
    mouse = values["-img-"]
    if mouse!=(None,None):
      axis = {
            "p_from": float(values["-p_from-"]),
            "p_to": float(values["-p_to-"]),
            "p_linear": values["-p_linear-"],
            "T_from": float(values["-T_from-"]),
            "T_to": float(values["-T_to-"]),
            "T_linear": values["-T_linear-"],
            "gradular_colors": values["-grad_cols-"],
        }
      T_set = calc_T(axis,mouse[0],image_size)
      p_set = calc_p(axis,mouse[1],image_size)
      window["-T_set-"].update("{}".format(T_set))
      window["-p_set-"].update("{}".format(p_set))
      
      name_g = values["-g_key-"]
      dG = calc_deltaG(name_g, T_set, p_set, T_set)
      window["-info_g-"].update("Gibbs Free Energy of {}: {} ".format(name_g, dG))
      
      name_b = values["-b_key-"]
      dG = calc_deltaG(name_b, T_set, p_set, T_set)
      window["-info_b-"].update("Gibbs Free Energy of {}: {} ".format(name_b, dG))
      
      name_r = values["-r_key-"]
      dG = calc_deltaG(name_r, T_set, p_set, T_set)
      window["-info_r-"].update("Gibbs Free Energy of {}: {} ".format(name_r, dG))
  elif event=="Recalculate":
    T_set = float(values["-T_set-"])
    p_set = float(values["-p_set-"])

    name_g = values["-g_key-"]
    dG = calc_deltaG(name_g, T_set, p_set, T_set)
    window["-info_g-"].update("Gibbs Free Energy of {}: {} ".format(name_g, dG))

    name_b = values["-b_key-"]
    dG = calc_deltaG(name_b, T_set, p_set, T_set)
    window["-info_b-"].update("Gibbs Free Energy of {}: {} ".format(name_b, dG))

    name_r = values["-r_key-"]
    dG = calc_deltaG(name_r, T_set, p_set, T_set)
    window["-info_r-"].update("Gibbs Free Energy of {}: {} ".format(name_r, dG))
  elif event=="Plot dG for const T":
    axis = {
            "p_from": float(values["-p_from-"]),
            "p_to": float(values["-p_to-"]),
            "p_const": float(values["-p_const-"]),
            "p_linear": values["-p_linear-"],
            "T_from": float(values["-T_from-"]),
            "T_to": float(values["-T_to-"]),
            "T_const": float(values["-T_const-"]),
            "T_linear": values["-T_linear-"],
            "gradular_colors": values["-grad_cols-"],
        }
    
    preas = []
    y_r = []
    y_g = []
    y_b = []
    v_r = v_g = v_b = False
    T_const = axis["T_const"]
    for x in range(image_size):
      preas.append(calc_p(axis, x, image_size))
      y_r.append(calc_deltaG(values["-r_key-"], T_const, preas[-1], T_const))
      y_g.append(calc_deltaG(values["-g_key-"], T_const, preas[-1], T_const))
      y_b.append(calc_deltaG(values["-b_key-"], T_const, preas[-1], T_const))
      if y_r[-1]!=0:
        v_r = True
      if y_g[-1]!=0:
        v_g = True
      if y_b[-1]!=0:
        v_b = True
      
    fig, ax = plot.subplots()
    plot.title("dG for const T: {} K (g; {}, b: {}, r: {})".format(T_const, values["-g_key-"], values["-b_key-"], values["-r_key-"]))
    if v_r:    
      ax.plot(preas, y_r, "r")
    if v_g:
      ax.plot(preas, y_g, "g")
    if v_b:
      ax.plot(preas, y_b, "b")
    plot.show()
  elif event=="Plot dG for const p":
    axis = {
            "p_from": float(values["-p_from-"]),
            "p_to": float(values["-p_to-"]),
            "p_const": float(values["-p_const-"]),
            "p_linear": values["-p_linear-"],
            "T_from": float(values["-T_from-"]),
            "T_to": float(values["-T_to-"]),
            "T_const": float(values["-T_const-"]),
            "T_linear": values["-T_linear-"],
            "gradular_colors": values["-grad_cols-"],
        }
    
    preas = []
    y_r = []
    y_g = []
    y_b = []
    v_r = v_g = v_b = False
    p_const = axis["p_const"]
    for x in range(image_size):
      preas.append(calc_T(axis, x, image_size))
      y_r.append(calc_deltaG(values["-r_key-"], preas[-1], p_const, preas[-1]))
      y_g.append(calc_deltaG(values["-g_key-"], preas[-1], p_const, preas[-1]))
      y_b.append(calc_deltaG(values["-b_key-"], preas[-1], p_const, preas[-1]))
      if y_r[-1]!=0:
        v_r = True
      if y_g[-1]!=0:
        v_g = True
      if y_b[-1]!=0:
        v_b = True
      
    fig, ax = plot.subplots()
    plot.title("dG for const p: {} Pa (g: {}, b; {}, r: {})".format(p_const, values["-g_key-"], values["-b_key-"], values["-r_key-"]))
    if v_r:
      ax.plot(preas, y_r, "r")
    if v_g:
      ax.plot(preas, y_g, "g")
    if v_b:
      ax.plot(preas, y_b, "b")
    plot.show()
  else:
    print("Unexpected event: {}".format(event))
    
window.close()
