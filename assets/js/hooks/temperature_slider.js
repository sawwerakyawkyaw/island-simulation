const TemperatureSlider = {
  mounted() {
    const slider = this.el;
    const valueElement = document.getElementById("tempThresholdValue");

    // Set initial styles
    slider.style.webkitAppearance = "none";
    slider.style.width = "100%";
    slider.style.height = "8px";
    slider.style.borderRadius = "4px";
    slider.style.background =
      "linear-gradient(to right, blue 0%, blue 0%, red 100%, red 100%)";
    slider.style.outline = "none";

    // Style the thumb (the draggable part)
    slider.style.cursor = "pointer";

    function updateSliderTrackColor() {
      const min = parseInt(slider.min);
      const max = parseInt(slider.max);
      const val = parseInt(slider.value);
      const percent = ((val - min) / (max - min)) * 100;

      // Update the gradient based on the current value
      slider.style.background = `linear-gradient(to right, blue 0%, blue ${percent}%, red ${percent}%, red 100%)`;
      if (valueElement) {
        valueElement.innerHTML = val;
      }
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
