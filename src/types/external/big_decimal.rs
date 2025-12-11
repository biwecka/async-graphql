use std::str::FromStr;

use bigdecimal::BigDecimal;

use crate::{InputValueError, InputValueResult, Scalar, ScalarType, Value};

#[Scalar(internal, name = "BigDecimal")]
impl ScalarType for BigDecimal {
    fn parse(value: Value) -> InputValueResult<Self> {
        match &value {
            Value::String(s) => Ok(BigDecimal::from_str(s)?),
            _ => Err(InputValueError::expected_type(value)),
        }
    }

    fn to_value(&self) -> Value {
        Value::String(self.to_string())
    }
}
