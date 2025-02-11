from PIL import Image

NomClassique = "exclusif_FOG"

def create_image_grid(NomClassique):
    Folder = "Z:/03_CartesTF/Stats_GI/GrandAverage/"

    # Open the 6 images
    img1 = Image.open(Folder + "TF_T0_STN-SM-" + NomClassique + "0_0.05.png")
    img2 = Image.open(Folder + "TF_T0_STN-SM-" + NomClassique + "1_0.05.png")
    img3 = Image.open(Folder + "TF_T0_STN-SM-" + NomClassique + "2_0.05.png")
    img4 = Image.open(Folder + "TF_T0_STN-AS-" + NomClassique + "0_0.05.png")
    img5 = Image.open(Folder + "TF_T0_STN-AS-" + NomClassique + "1_0.05.png")
    img6 = Image.open(Folder + "TF_T0_STN-AS-" + NomClassique + "2_0.05.png")


    # Create a new image with the size of the grid (2x3)
    grid_size = (2, 3)
    grid_width = img1.width * grid_size[1]
    grid_height = img1.height * grid_size[0]
    grid_image = Image.new("RGB", (grid_width, grid_height))

    # Paste the images onto the grid
    grid_image.paste(img1, (0, 0))
    grid_image.paste(img2, (img1.width, 0))
    grid_image.paste(img3, (img1.width*2, 0))
    grid_image.paste(img4, (0, img1.height))
    grid_image.paste(img5, (img1.width, img1.height))
    grid_image.paste(img6, (img1.width*2, img1.height))

    # Save the grid image
    grid_image.save(Folder + "TF_T0_STN-Grid_" + NomClassique + ".png")


create_image_grid("exclusif-GrandAverage_FOG")
create_image_grid("exclusif-GrandAverage_FOGco")
create_image_grid("exclusif-GrandAverage_FOGch")
create_image_grid("exclusif-GrandAverage_FOGta")
create_image_grid("exclusif-GrandAverage_FOGtr")
create_image_grid("exclusif-GrandAverage_FOGpa")