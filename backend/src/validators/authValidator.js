const emailRegex = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;

const validateRegister = (data) => {
  if (!data || typeof data !== 'object') {
    return 'Request body must be a JSON object';
  }

  const { name, email, password } = data;

  if (!name || typeof name !== 'string' || name.trim().length < 2) {
    return 'Full name is required and must be at least 2 characters';
  }

  if (!email || typeof email !== 'string' || !emailRegex.test(email.trim())) {
    return 'A valid email address is required';
  }

  if (!password || typeof password !== 'string' || password.length < 6) {
    return 'Password is required and must be at least 6 characters';
  }

  return null;
};

const validateLogin = (data) => {
  if (!data || typeof data !== 'object') {
    return 'Request body must be a JSON object';
  }

  const { email, password } = data;

  if (!email || typeof email !== 'string' || !emailRegex.test(email.trim())) {
    return 'A valid email address is required';
  }

  if (!password || typeof password !== 'string' || password.length < 6) {
    return 'Password is required and must be at least 6 characters';
  }

  return null;
};

const validateProfileUpdate = (data) => {
  if (!data || typeof data !== 'object') {
    return 'Request body must be a JSON object';
  }

  const { name } = data;

  if (name !== undefined) {
    if (typeof name !== 'string' || name.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
  }

  return null;
};

module.exports = {
  validateRegister,
  validateLogin,
  validateProfileUpdate,
};
