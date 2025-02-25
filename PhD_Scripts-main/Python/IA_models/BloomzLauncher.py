# -*- coding: utf-8 -*-
"""
Created on Fri Feb 17 13:40:49 2023

@author: mathieu.yeche
"""
inputs = "Subthalamic nucleus deep brain stimulation"
ModelToUse = "BloomZ"
meanLength = 1024

if ModelToUse == "BloomZ":
    from transformers import pipeline, set_seed
    from transformers import AutoModelForCausalLM, AutoTokenizer
    
    checkpoint = "bigscience/bloomz-7b1-mt"
    
    
    tokenizer = AutoTokenizer.from_pretrained(checkpoint)
    model = AutoModelForCausalLM.from_pretrained(checkpoint, torch_dtype="auto", device_map="auto")
    
    print(tokenizer.decode(model.generate(tokenizer.encode(inputs, return_tensors="pt").to("cuda"), max_new_tokens = round(meanLength * 1.4), min_length = round(meanLength * 0.6))[0]))
    
    
if ModelToUse == "bioGPT":
    from transformers import pipeline, set_seed
    
    
    
    