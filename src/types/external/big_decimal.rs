use std::str::FromStr;

use bigdecimal::BigDecimal;

use crate::{InputValueError, InputValueResult, Scalar, ScalarType, Value};

#[Scalar(internal, name = "BigDecimal")]
impl ScalarType for BigDecimal {
    fn parse(value: Value) -> InputValueResult<Self> {
        println!("[BigDecimal] value={value:?}");

        match &value {
            Value::Number(n) => {
                println!("[BigDecimal] value is a number");

                if let Some(f) = n.as_f64() {
                    println!("[BigDecimal] value is a f64: {f}");
                    return BigDecimal::try_from(f).map_err(InputValueError::custom);
                }

                if let Some(f) = n.as_i64() {
                    println!("[BigDecimal] value is a i64: {f}");
                    return Ok(BigDecimal::from(f));
                }

                println!("[BigDecimal] value is 'probably' a u64: {}", n.as_u64().unwrap());

                // unwrap safe here, because we have check the other possibility
                Ok(BigDecimal::from(n.as_u64().unwrap()))
            }
            Value::String(s) => {
                println!("[BigDecimal] value is a string '{s}': {:?}", BigDecimal::from_str(s));
                Ok(BigDecimal::from_str(s)?)
            },
            _ => Err(InputValueError::expected_type(value)),
        }
    }

    fn to_value(&self) -> Value {
        Value::String(self.to_string())
    }
}
