const validateCreateDestination = (data) => {
  if (!data || typeof data !== 'object') {
    return 'Request body must be a JSON object';
  }

  const { name, country, subtitle, description } = data;

  if (!name || typeof name !== 'string' || name.trim() === '') {
    return 'Destination name is required';
  }

  if (!country || typeof country !== 'string' || country.trim() === '') {
    return 'Country is required';
  }

  if (!subtitle || typeof subtitle !== 'string' || subtitle.trim() === '') {
    return 'Subtitle is required';
  }

  if (!description || typeof description !== 'string' || description.trim() === '') {
    return 'Description is required';
  }

  return null;
};

const validateUpdateDestination = (data) => {
  if (!data || typeof data !== 'object') {
    return 'Request body must be a JSON object';
  }

  if (data.name !== undefined && (typeof data.name !== 'string' || data.name.trim() === '')) {
    return 'Destination name cannot be empty';
  }

  if (data.country !== undefined && (typeof data.country !== 'string' || data.country.trim() === '')) {
    return 'Country cannot be empty';
  }

  return null;
};

module.exports = {
  validateCreateDestination,
  validateUpdateDestination,
};
