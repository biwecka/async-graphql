use std::str::FromStr;

use bigdecimal::BigDecimal;

use crate::{InputValueError, InputValueResult, Scalar, ScalarType, Value};

#[Scalar(internal, name = "BigDecimal")]
impl ScalarType for BigDecimal {
    fn parse(value: Value) -> InputValueResult<Self> {
        println!("[BigDecimal] value={value:?}");

        match &value {
            Value::String(s) => {
                let val = BigDecimal::from_str(s)?;
                println!("[BigDecimal] value is a string '{s}' => {:?}", val);
                Ok(val)
            },

            _ => Err(InputValueError::expected_type(value)),
        }
    }

    fn to_value(&self) -> Value {
        Value::String(self.to_string())
    }
}
