from minizinc import Instance, Model, Solver
from PIL import Image, ImageDraw

width = 2500
height = 500

housesData = [
    [0, 0, 200, 200],
    [50, 250, 200, 250],
    [300, 300, 150, 150],
    [1800, 100, 350, 350],
    [850, 125, 240, 180],
    [1200, 200, 200, 200],
]

antennasModel = Model("./antennas.mzn")
gecode = Solver.lookup("chuffed")
instance = Instance(gecode, antennasModel)
instance["antennasRadius"] = {100, 250}
instance["housesData"] = housesData
result = instance.solve()

im = Image.new('RGBA', (width, height), (255, 255, 255))
ov = Image.new('RGBA', (width, height), (255, 255, 255, 55))
draw = ImageDraw.Draw(im)
draw2 = ImageDraw.Draw(ov)

antennasData = result["antennasData"]
included = result["included"]
radiusData = result["radiusData"]

for house in housesData:
    draw.rectangle(
        (house[0], house[1], house[0] + house[2], house[1] + house[3]),
        fill="white",
        outline=(0, 0, 0, 127),
        width=2
    )

for i in included:
    idx = i - 1
    x = antennasData[idx][0]
    y = antennasData[idx][1]
    r = radiusData[idx]
    draw2.ellipse((x - r, y - r, x + r, y + r), fill=(200, 100, 0, 40), outline=(0, 0, 0, 40), width=2)

im = Image.alpha_composite(im, ov)
im = im.convert('RGBA')
im.save('result.png')

print(result)
