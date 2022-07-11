#include "lab5.h"
	
takemost(unsigned char* chunk1, unsigned char* chunk2)
{
	return (chunk1 > chunk2) ? chunk1 : chunk2;
}

void grayImage(unsigned char* chunk, unsigned char* out, int width, int height, int channels, int line){
    int capacity = line * channels;
  for(int y = 0; y < height; y++)
  {
      int offset = 0;
      int k = line;
      for(int x = 0; x < width; x++)
      {
          if(k<= 0){
              k = line;
              offset = offset == 2 ? 0 : (offset + 1);
          }
          k--;
          int whereI = (y * width+x) * channels;
	  if(channels == 4) out[whereI + 3] = chunk[whereI + 3];
          unsigned char max = chunk[whereI + 0] > chunk[whereI + 1] ? chunk[whereI] : chunk[whereI + 1];
            max = max > chunk[whereI + 2] ? max : chunk[whereI + 2];
            out[whereI] = out[whereI + 1] = out[whereI + 2] = 0;
            out[whereI + offset] = max;
      }
  }
}

void timing(){
   char inputList[5][15] = {"imgs/5.png", "imgs/4.png", "imgs/3.png", "imgs/2.png", "imgs/1.png"};
   char outputList[10][15] = {"imgs/5resa.png", "imgs/4resa.png", "imgs/3resa.png", "imgs/2resa.png", "imgs/1resa.png","imgs/5res.png", "imgs/4res.png", "imgs/3res.png", "imgs/2res.png", "imgs/1res.png"};
   clock_t t;
   double time;
   int width, channels, height;
   unsigned char* inputData = NULL;
   unsigned char* outputData = NULL;
   unsigned char* outputDataC = NULL;
   unsigned char* outputDataASM = NULL;
   for(int i = 0; i < 5; ++i){
       printf("---image %d---\n", i + 1);
       inputData = stbi_load(inputList[i], &width, &height, &channels,0);
       outputDataC = malloc(height*channels*width);
/*       outputDataASM = malloc(height * channels *width);
       t = clock();
       AsmGray(inputData, outputDataASM, width, height, channels);
       t = clock() - t;
       time = ((double)t) / CLOCKS_PER_SEC;
       stbi_write_png(outputList[i], width, height, channels, outputDataASM, width * channels);
  */     printf("Asm: %f\n", time);
       t = clock();
       int line = 100;
       grayImage(inputData, outputDataC, width, height, channels, line);
       t = clock() - t;
       time = ((double)t) / CLOCKS_PER_SEC;
       printf("C:   %f\n", time);
       stbi_write_png(outputList[i+5], width, height, channels, outputDataC, width * channels);
       stbi_image_free(inputData);
       free(outputDataASM);
       free(outputDataC);
   }
}

int main(int argc, char** argv){
    if (argc == 1){
        timing();
        exit(1);
    }
    if (argc != 3){
        fprintf(stderr, "Usage: %s <input_file> <output_file>\n", argv[0]);
        exit(-1);
    }
    char* input = argv[1];
    char* output = argv[2];
    if (access(input, F_OK) != 0){//test for file existance
        fprintf(stderr, "Input file doesn't exist\n");
        exit(-1);
    }
    int fd = open(output, O_WRONLY | O_CREAT | O_TRUNC, 0666);
    if(fd < 0){
        fprintf(stderr, "Can't open output file\n");
        exit(-1);
    }
    close(fd);
    int width, height, channels;
    unsigned char* inputData = NULL;
    inputData = stbi_load(input, &width, &height, &channels, 0);		//???
    if(!inputData){
        fprintf(stderr, "Can't load image\n");
        exit(-1);
    }
    unsigned char* outputData = NULL;
    outputData = malloc(width*height*channels);
    if (outputData == NULL){
        fprintf(stderr, "Failed to allocate memory\n");
        exit(-1);
    }
    AsmGray(inputData, outputData, width, height, channels);
    width = width/2;
    height = height/2;

    stbi_write_png(output, width, height, channels, outputData, width * channels);
    stbi_image_free(inputData);
    free(outputData);
}
