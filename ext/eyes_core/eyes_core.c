#include "eyes_core.h"

void Init_eyes_core() {
  VALUE Applitools = rb_define_module("Applitools");
  VALUE Resampling = rb_define_module_under(Applitools, "ResamplingFast");
  rb_define_method(Resampling, "resampling_first_step", c_resampling_first_step, 2);
};

VALUE c_resampling_first_step(VALUE self, VALUE dst_dimension_x, VALUE dst_dimension_y) {
    PIXEL *source, *destination;
    unsigned long int source_width, source_height, c_dst_dimension_x, c_dst_dimension_y, w_m, h_m;
    VALUE result_array;

    source_width = NUM2UINT(rb_funcall(self, rb_intern("width"), 0, NULL));
    source_height = NUM2UINT(rb_funcall(self, rb_intern("height"), 0, NULL));

    c_dst_dimension_x = NUM2UINT(dst_dimension_x);
    c_dst_dimension_y = NUM2UINT(dst_dimension_y);

    w_m = source_width / c_dst_dimension_x;
    h_m = source_height / c_dst_dimension_y;

    if (w_m == 0) {
      w_m = 1;
    };

    if (h_m == 0) {
      h_m = 1;
    };

    source = get_c_array(self);

    destination = get_bicubic_points(source, source_width, source_height, c_dst_dimension_x * w_m, c_dst_dimension_y * h_m);

    if (w_m * h_m > 1) {
      source = destination;
      destination = c_scale_points(source, c_dst_dimension_x, c_dst_dimension_y, w_m, h_m);
    }

    result_array = get_ruby_array(self, destination, c_dst_dimension_x * c_dst_dimension_y);
    free(destination);
    return result_array;
};

VALUE get_ruby_array(VALUE self, PIXEL *pixels, unsigned long int pixels_size) {
    VALUE result_array;
    unsigned long int i;
    result_array = rb_ary_new2(pixels_size);
    for (i=0; i<pixels_size; i++) {
      rb_ary_store(result_array, i, UINT2NUM(pixels[i]));
    };
    return result_array;
}

PIXEL* get_c_array(VALUE self) {
  unsigned long int w,h,i;
  PIXEL* ary;
  VALUE pixels;

  pixels = rb_funcall(self, rb_intern("pixels"), 0, NULL);
  w = NUM2UINT(rb_funcall(self, rb_intern("width"), 0, NULL));
  h = NUM2UINT(rb_funcall(self, rb_intern("height"), 0, NULL));
  ary = (PIXEL*)malloc( w*h*sizeof(PIXEL));

  for(i=0; i<w*h; i++) {
    ary[i] = NUM2UINT(rb_ary_entry(pixels, i));
  }

  return ary;
}

PIXEL raw_interpolate_cubic(double t, PIXEL p0, PIXEL p1, PIXEL p2, PIXEL p3) {
  BYTE  new_r, new_g, new_b, new_a;

  new_r = interpolate_char(t, R_BYTE(p0), R_BYTE(p1), R_BYTE(p2), R_BYTE(p3));
  new_g = interpolate_char(t, G_BYTE(p0), G_BYTE(p1), G_BYTE(p2), G_BYTE(p3));
  new_b = interpolate_char(t, B_BYTE(p0), B_BYTE(p1), B_BYTE(p2), B_BYTE(p3));
  new_a = interpolate_char(t, A_BYTE(p0), A_BYTE(p1), A_BYTE(p2), A_BYTE(p3));

  return BUILD_PIXEL(new_r, new_g, new_b, new_a);
}

BYTE interpolate_char(double t, BYTE c0, BYTE c1, BYTE c2, BYTE c3) {
  double a, b, c, d, res;
  a = - 0.5 * c0 + 1.5 * c1 - 1.5 * c2 + 0.5 * c3;
  b = c0 - 2.5 * c1 + 2 * c2 - 0.5 * c3;
  c = 0.5 * c2 - 0.5 * c0;
  d = c1;
  res = a * t * t * t + b * t * t + c * t + d + 0.5;
  if(res < 0) {
    res = 0;
  } else if(res > 255) {
    res = 255;
  };
  return (BYTE)(res);
};

PIXEL raw_merge_pixels(PIXEL* merge_pixels, unsigned int size) {
  unsigned int i, real_colors, acum_r, acum_g, acum_b, acum_a;
  BYTE new_r, new_g, new_b, new_a;
  PIXEL pix;

  acum_r = 0;
  acum_g = 0;
  acum_b = 0;
  acum_a = 0;

  new_r = 0;
  new_g = 0;
  new_b = 0;
  new_a = 0;

  real_colors = 0;

  for(i=0; i < size; i++) {
    pix = merge_pixels[i];
    if(A_BYTE(pix) != 0) {
      acum_r += R_BYTE(pix);
      acum_g += G_BYTE(pix);
      acum_b += B_BYTE(pix);
      acum_a += A_BYTE(pix);
      real_colors += 1;
    };
  };

  if(real_colors > 0) {
    new_r = (BYTE)(acum_r/real_colors);
    new_g = (BYTE)(acum_g/real_colors);
    new_b = (BYTE)(acum_b/real_colors);
  };
  new_a = (BYTE)(acum_a/size);
  return BUILD_PIXEL(new_r, new_g, new_b, new_a);
};

void setup_steps_residues(unsigned long int *steps, double *residues,
  unsigned long int src_dimension, unsigned long int dst_dimension) {
  unsigned long int i;
  double step = (double) (src_dimension - 1) / (dst_dimension - 1);
  for(i = 0; i < dst_dimension - 1; i++) {
    steps[i] = (unsigned long int) i*step;
    residues[i]  = i*step - steps[i];
  };

  steps[dst_dimension - 1] = src_dimension - 2;
  residues[dst_dimension - 1] = 1;
};

PIXEL get_line_pixel(PIXEL* source, unsigned long int line, long int pixel,
  unsigned long int src_dimension_x) {
  if(pixel >= 0 && pixel < (long int)src_dimension_x) {
    return source[line * src_dimension_x + pixel];
  } else {
    return 0;
  };
};

PIXEL get_column_pixel(PIXEL* source,
  unsigned long int column, long int pixel,
  unsigned long int src_dimension_y, unsigned long int src_dimension_x) {

  if(pixel >=0 && pixel < (long int)src_dimension_y) {
    return source[src_dimension_x * pixel + column];
  } else {
    return 0;
  };
};

PIXEL* get_bicubic_points(PIXEL* source_array,
  unsigned long int src_dimension_x, unsigned long int src_dimension_y,
  unsigned long int dst_dimension_x, unsigned long int dst_dimension_y) {
  PIXEL* dest, *source;
  unsigned long int index_y, index, y, x;
  unsigned long int* steps;
  double* residues;

  steps = (unsigned long int*) malloc(dst_dimension_x * sizeof(unsigned long int));
  residues = (double*) malloc(dst_dimension_x * sizeof(double));
  setup_steps_residues(steps, residues, src_dimension_x, dst_dimension_x);

  source = source_array;
  dest = (PIXEL*)malloc( src_dimension_y*dst_dimension_x*sizeof(PIXEL) );

  for (y=0; y < src_dimension_y; y++) {
    index_y = dst_dimension_x * y;
    for (x=0; x < dst_dimension_x; x++) {
      index = index_y + x;
      dest[index] = raw_interpolate_cubic(residues[x],
        get_line_pixel(source, y, steps[x] - 1, src_dimension_x),
        get_line_pixel(source, y, steps[x], src_dimension_x),
        get_line_pixel(source, y, steps[x] + 1, src_dimension_x),
        get_line_pixel(source, y, steps[x] + 2, src_dimension_x)
      );
    };
  };

  steps = realloc(steps, dst_dimension_y * sizeof(unsigned long int));
  residues = realloc(residues, dst_dimension_y * sizeof(double));
  setup_steps_residues(steps, residues, src_dimension_y, dst_dimension_y);

  free(source);
  source = dest;
  dest = (PIXEL*)malloc( dst_dimension_x * dst_dimension_y * sizeof(PIXEL));

  for (y=0; y < dst_dimension_x; y++) {
    for (x=0; x < dst_dimension_y; x++) {
      index = dst_dimension_x * x + y;
      dest[index] = raw_interpolate_cubic(residues[x],
        get_column_pixel(source, y, steps[x] - 1, src_dimension_y, dst_dimension_x),
        get_column_pixel(source, y, steps[x], src_dimension_y, dst_dimension_x),
        get_column_pixel(source, y, steps[x] + 1, src_dimension_y, dst_dimension_x),
        get_column_pixel(source, y, steps[x] + 2, src_dimension_y, dst_dimension_x)
      );
    };
  };

  free(source);
  free(steps);
  free(residues);

  return dest;
};

PIXEL* c_scale_points(PIXEL* source, unsigned long int dst_width, unsigned long int dst_height,
  unsigned long int w_m, unsigned long int h_m) {

  unsigned long int y_pos, x_pos, index, i, j, x, y, buffer_size, buffer_index;
  PIXEL* pixels_to_merge;
  PIXEL* result;

  pixels_to_merge = malloc(w_m*h_m*sizeof(PIXEL));
  result = malloc(dst_width * dst_height * sizeof(PIXEL));

  buffer_size = h_m * w_m;

  for (i = 0; i < dst_height; i++) {
    for (j = 0; j < dst_width; j++) {
      buffer_index = 0;
      for (y = 0; y < h_m; y++) {
        y_pos = i * h_m + y;
        for (x = 0; x < w_m; x++) {
          x_pos = j * w_m + x;
          pixels_to_merge[buffer_index++] = source[dst_width * w_m * y_pos + x_pos];
        };
      };
      index = i * dst_width + j;
      result[index] = raw_merge_pixels(pixels_to_merge, buffer_size);

    };
  };
  free(source);
  return result;
};