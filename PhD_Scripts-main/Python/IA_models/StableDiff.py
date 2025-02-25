
# Choose Python 3.10 (GTP) as conda environment

prompt = "Medical doctor with a coat and stethoscope (around is neck) skiing on a vanilla icecream (giant italian icecream). The doctor skier is skiing on the slope formed by this giant icecream cone in a vintage style"
prompt = "Subthalamic nucleus receiving input from 3 differents cortical areas. the anterior part is located on the left. the connections are colored in a shade from sky magenta (left) to dark cyan (right)"
prompt = "Basal ganglia receiving fiber input from 3 differents cortical areas. Artistic view. do not put any annotation. show the basal ganglia network. the connections are colored in a shade from sky magenta to dark cyan. One basal ganglia nucleus in gold yellow. Abtract artistic view"
type   = "image" # "image" or "txt2video" or "img2video"

if type == "img2video":
    # WIP
    from PIL import Image
    image = Image.open("C:/Users/mathieu.yeche/Desktop/IA_Output/image_" + prompt +".png")

from diffusers import DiffusionPipeline
import torch


# load both base & refiner
print("Chargement du modèle")
base = DiffusionPipeline.from_pretrained("stabilityai/stable-diffusion-xl-base-1.0", torch_dtype=torch.float16, variant="fp16", use_safetensors=True).to("cuda")
refiner = DiffusionPipeline.from_pretrained(
    "stabilityai/stable-diffusion-xl-refiner-1.0",
    text_encoder_2=base.text_encoder_2, vae=base.vae,
    torch_dtype=torch.float16, variant="fp16", use_safetensors=True,
).to("cuda")

# Define how many steps and what % of steps to be run on each experts (80/20) here
n_steps = 20
high_noise_frac = 0.8

# run both experts
print("Création de l'image")
image = base(
    prompt=prompt,
    num_inference_steps=n_steps,
    denoising_end=high_noise_frac,
    output_type="latent",
).images
image.save("C:/Users/mathieu.yeche/Desktop/IA_Output/lowres/image_" + prompt +".png")
image = refiner(
    prompt=prompt,
    num_inference_steps=n_steps,
    denoising_start=high_noise_frac,
    image=image,
).images[0]

# save image
print("Export de l'image")
image.save("C:/Users/mathieu.yeche/Desktop/IA_Output/image_" + prompt +".png")


if type == "txt2video" | type == "img2video":
    # todo
    0
