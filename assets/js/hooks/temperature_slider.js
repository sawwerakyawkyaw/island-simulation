const TemperatureSlider = {
  mounted() {
    const slider = this.el;
    const valueElement = document.getElementById("tempThresholdValue");

    function updateSliderTrackColor() {
      const min = parseInt(slider.min);
      const max = parseInt(slider.max);
      const val = parseInt(slider.value);
      const percent = ((val - min) / (max - min)) * 100;

      slider.style.background = `linear-gradient(to right, blue 0%, blue ${percent}%, red ${percent}%, red 100%)`;
      valueElement.innerHTML = val;
    }

    // Initialize with current value
    updateSliderTrackColor();

    // Update on input
    slider.addEventListener("input", () => {
      updateSliderTrackColor();
    });
  },
};

export default TemperatureSlider;
