class LucasKanade {
  float[][] current;
  float[][] buffer;
  float[][] buffer2;
  float[][] buffer3;
  int width_buffer, height_buffer, window_size;
  LucasKanade(int _width_buffer, int _height_buffer , int _window_size) {
    width_buffer = _width_buffer;
    height_buffer = _height_buffer;
    window_size = _window_size;
    current = new float[width_buffer][height_buffer];
    buffer = new float[width_buffer][height_buffer];
    buffer2 = new float[width_buffer][height_buffer];
    buffer3 = new float[width_buffer][height_buffer];
  }

  float[][] from_img_to_buf(PImage img) {
    float[][] buf = new float[width_buffer][height_buffer];
    img = img.copy();
    img.resize(width_buffer, height_buffer);
    for (int i=0; i<width_buffer; i++) {
      for (int j=0; j<height_buffer; j++) {
        buf[i][j] = green(img.get(i, j));
      }
    }
    return buf;
  }

  float[][] copy_buf(float[][] buf_in) {
    float[][] buf = new float[width_buffer][height_buffer];
    for (int i=0; i<width_buffer; i++) {
      for (int j=0; j<height_buffer; j++) {
        buf[i][j] = buf_in[i][j];
      }
    }
    return buf;
  }

  void shift_buffer(PImage videoFrame) {
    buffer = copy_buf(buffer2);
    buffer2 = copy_buf(buffer3);
    buffer3 = copy_buf(current);
    current = from_img_to_buf(videoFrame);
  }
  
  float[][][] optical_flow()  {
    return optical_flow(current, buffer, window_size);
  }

  float[][][] optical_flow(float[][] cur, float[][] buf, int window) {
    int cols = cur.length;
    int rows = cur[0].length;

    float[][][] flow = new float[cols][rows][2]; // 3D-Array für optischen Fluss (x- und y-Richtung)

    // Iteriere über alle Pixel im Bild
    for (int x = 0; x < cols; x++) {
      for (int y = 0; y < rows; y++) {

        // Ignoriere den Rand des Bildes, um sicherzustellen, dass das Fenster vollständig innerhalb des Bildes liegt
        if (true) {

          // Extrahiere die Fensterregion um den aktuellen Pixel aus den beiden Bildern
          float[][] curWindow = getWindow(cur, x, y, window);
          float[][] bufWindow = getWindow(buf, x, y, window);

          // Berechne den Gradienten für beide Bilder
          float[][] Ix = gradientX(curWindow);
          float[][] Iy = gradientY(curWindow);

          // Berechne den Gradienten in der Zeit (zwischen den beiden Bildern)
          float[][] It = subtract(bufWindow, curWindow);

          // Forme die Matrizen für die Berechnung der optischen Flussparameter
          float[] IxArray = flatten(Ix);
          float[] IyArray = flatten(Iy);
          float[] ItArray = flatten(It);

          // Berechne die Pseudoinverse der Designmatrix
          //float[][] A = buildDesignMatrix(IxArray, IyArray);

          //float[][] M = float[2][2];
          float IxIx = 0;
          float IyIy = 0;
          float IxIy = 0;
          float ItIx = 0;
          float ItIy = 0;

          for (int i = 0; i < IxArray.length; i++) {
            IxIx += IxArray[i]*IxArray[i];
            IyIy += IyArray[i]*IyArray[i];
            IxIy += IxArray[i]*IyArray[i];

            ItIx += ItArray[i]*IxArray[i];
            ItIy += ItArray[i]*IyArray[i];
          }

          float regularizer = 0.0001;
          IxIx += regularizer;
          IyIy += regularizer;
          /*
        [ IxIx    IxIy  ]  [  -ItIx]
           [ IxIy    IyIy  ]  [  -ItIy]
           
           det = IxIx*IyIy - IxIy*IxIy;
           
           [ (-ItIx)   IxIy  ]
           [ ( -ItIy)  IyIy  ] 
           
           detA = (-ItIx)*IyIy - (-ItIy)*IxIy
           
           [ IxIx    (-ItIx)  ]
           [ IxIy    ( -ItIy) ]
           
           detB = IxIx*(-ItIy) - IxIy*(-ItIx)
           */

          float det = IxIx*IyIy - IxIy*IxIy;
          float detA = (-ItIx)*IyIy - (-ItIy)*IxIy;
          float detB = IxIx*(-ItIy) - IxIy*(-ItIx);

          float[] uv = {detA/det, detB/det};
          /*float[] uv = solve_2d(A, ItArray);
           
           // Berechne die optischen Flussparameter
           float[] uv = pseudoInverseA.times(new Matrix(ItArray, ItArray.length)).getColumnPackedCopy();
           */

          // Speichere den optischen Fluss in das 3D-Array
          flow[x][y][0] = uv[0]; // x-Richtung
          flow[x][y][1] = uv[1]; // y-Richtung
        }
      }
    }

    return flow;
  }

  float[][] getWindow(float[][] image, int x, int y, int window) {
    float[][] windowValues = new float[window * 2 + 1][window * 2 + 1];

    for (int i = -window; i <= window; i++) {
      for (int j = -window; j <= window; j++) {
        if (x + i < 0 || y + j < 0 || x + i >= width_buffer || y + j >= height_buffer) {
          windowValues[i + window][j + window] = 0;
        } else {
          windowValues[i + window][j + window] = image[x + i][y + j];
        }
      }
    }

    return windowValues;
  }

  float[][] gradientX(float[][] image) {
    int cols = image.length;
    int rows = image[0].length;

    float[][] result = new float[cols][rows];

    for (int x = 1; x < cols - 1; x++) {
      for (int y = 0; y < rows; y++) {
        result[x][y] = (image[x + 1][y] - image[x - 1][y]) * 0.5;
      }
    }

    return result;
  }

  float[][] gradientY(float[][] image) {
    int cols = image.length;
    int rows = image[0].length;

    float[][] result = new float[cols][rows];

    for (int x = 0; x < cols; x++) {
      for (int y = 1; y < rows - 1; y++) {
        result[x][y] = (image[x][y + 1] - image[x][y - 1]) * 0.5;
      }
    }

    return result;
  }

  float[][] subtract(float[][] A, float[][] B) {
    int cols = A.length;
    int rows = A[0].length;

    float[][] result = new float[cols][rows];

    for (int x = 0; x < cols; x++) {
      for (int y = 0; y < rows; y++) {
        result[x][y] = A[x][y] - B[x][y];
      }
    }

    return result;
  }

  float[] flatten(float[][] array) {
    int cols = array.length;
    int rows = array[0].length;

    float[] flattened = new float[cols * rows];

    for (int x = 0; x < cols; x++) {
      for (int y = 0; y < rows; y++) {
        flattened[x * rows + y] = array[x][y];
      }
    }

    return flattened;
  }

  float[][] buildDesignMatrix(float[] IxArray, float[] IyArray) {
    int length = IxArray.length;

    float[][] designMatrixData = new float[length][2];
    for (int i = 0; i < length; i++) {
      designMatrixData[i][0] = IxArray[i];
      designMatrixData[i][1] = IyArray[i];
    }

    return designMatrixData;
  }
}
